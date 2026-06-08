import os
import json
import gzip
import shutil
from pathlib import Path
from datetime import datetime
from typing import Any, Dict, List

import time

from bson import ObjectId
from pymongo import MongoClient, ASCENDING
from google.cloud import storage
from dotenv import load_dotenv

load_dotenv()

BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR / ".env")

MONGO_URI = os.getenv("MONGO_URI")
DB_NAME = os.getenv("DB_NAME")
COLLECTION_NAME = os.getenv("MONGO_COLLECTION")

GCS_BUCKET = os.getenv("GCS_BUCKET")
GCS_PREFIX = os.getenv("GCS_PREFIX", "mongo_export")

LOCAL_DIR = Path(os.getenv("OUTPUT_DIR", "data"))

CHECKPOINT_FILE = Path("checkpoint.json")

BATCH_SIZE = 50000
SAMPLE_SIZE = 20000
DOCS_PER_FILE = 1000000

LOCAL_DIR.mkdir(exist_ok=True)


def json_safe(value: Any) -> str:
    if value is None:
        return ""

    if isinstance(value, ObjectId):
        return str(value)

    if isinstance(value, datetime):
        return value.isoformat()

    if isinstance(value, (dict, list)):
        return json.dumps(value, ensure_ascii=False, default=str)

    return str(value)


def flatten_doc(doc: Dict[str, Any], parent_key: str = "") -> Dict[str, str]:
    flat = {}

    for key, value in doc.items():
        new_key = f"{parent_key}_{key}" if parent_key else key
        new_key = new_key.replace(".", "_").replace("-", "_")

        if isinstance(value, dict):
            nested = flatten_doc(value, new_key)
            flat.update(nested)
        else:
            flat[new_key] = json_safe(value)

    return flat


def load_checkpoint():
    if CHECKPOINT_FILE.exists():
        return json.loads(CHECKPOINT_FILE.read_text())

    return {
        "last_id": None,
        "part": 1,
        "total_exported": 0
    }


def save_checkpoint(last_id, part, total_exported):
    CHECKPOINT_FILE.write_text(json.dumps({
        "last_id": str(last_id) if last_id else None,
        "part": part,
        "total_exported": total_exported
    }, indent=2))


def infer_fields(collection) -> List[str]:
    fields = set()

    cursor = collection.find({}, limit=SAMPLE_SIZE).sort("_id", ASCENDING)

    for doc in cursor:
        flat = flatten_doc(doc)
        fields.update(flat.keys())

    fields = sorted(fields)

    Path("schema_fields.json").write_text(
        json.dumps(fields, indent=2, ensure_ascii=False)
    )

    print(f"Inferred {len(fields)} fields.")
    return fields


def upload_to_gcs(local_path: Path):
    client = storage.Client()
    bucket = client.bucket(GCS_BUCKET)

    blob_name = f"{GCS_PREFIX}/{local_path.name}"
    blob = bucket.blob(blob_name)
    blob.upload_from_filename(str(local_path))

    print(f"Uploaded: gs://{GCS_BUCKET}/{blob_name}")


def export():
    start_time = time.time()
    last_log_time = start_time

    client = MongoClient(MONGO_URI)
    collection = client[DB_NAME][COLLECTION_NAME]

    checkpoint = load_checkpoint()
    last_id = checkpoint["last_id"]
    part = checkpoint["part"]
    total_exported = checkpoint["total_exported"]

    if Path("schema_fields.json").exists():
        fields = json.loads(Path("schema_fields.json").read_text())
    else:
        fields = infer_fields(collection)

    query = {}
    if last_id:
        query = {"_id": {"$gt": ObjectId(last_id)}}

    cursor = (
        collection
        .find(query)
        .sort("_id", ASCENDING)
        # .limit(10000)
        .batch_size(BATCH_SIZE)
    )

    current_count = 0
    current_file = LOCAL_DIR / f"part_{part:05d}.jsonl.gz"
    f = gzip.open(current_file, "at", encoding="utf-8", compresslevel=1)

    try:
        for doc in cursor:
            flat = flatten_doc(doc)

            row = {field: flat.get(field, "") for field in fields}

            f.write(json.dumps(row, ensure_ascii=False) + "\n")

            current_count += 1
            total_exported += 1
            last_id = doc["_id"]

            if total_exported % 100000 == 0:
                elapsed = time.time() - start_time
                rate = total_exported / elapsed

                print(
                    f"[{time.strftime('%H:%M:%S')}] "
                    f"Exported {total_exported:,} docs "
                    f"| Part {part} "
                    f"| Speed: {rate:,.0f} docs/sec "
                    f"| Elapsed: {elapsed/60:.1f} min"
    )

            if current_count >= DOCS_PER_FILE:
                f.close()

                upload_to_gcs(current_file)
                current_file.unlink()

                save_checkpoint(last_id, part + 1, total_exported)

                print(f"Finished part {part}, total exported: {total_exported}")

                part += 1
                current_count = 0
                current_file = LOCAL_DIR / f"part_{part:05d}.jsonl.gz"
                f = gzip.open(current_file, "at", encoding="utf-8", compresslevel=1)

        f.close()

        if current_count > 0:
            upload_to_gcs(current_file)
            current_file.unlink()
            save_checkpoint(last_id, part + 1, total_exported)

        elapsed = time.time() - start_time

        print(
            f"\nDone.\n"
            f"Total exported: {total_exported:,}\n"
            f"Time: {elapsed/60:.2f} min\n"
            f"Avg speed: {total_exported/elapsed:,.0f} docs/sec"
        )

    finally:
        cursor.close()
        client.close()


if __name__ == "__main__":
    export()