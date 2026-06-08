import json
import math
from datetime import datetime
from pymongo import MongoClient
from bson import ObjectId

client = MongoClient("mongodb://localhost:27017")
collection = client["glamira"]["summary"]

OUTPUT_FILE = "summary_sample_100k_bq_safe.jsonl"
LIMIT = 100000

def clean_value(value):
    if isinstance(value, ObjectId):
        return str(value)

    if isinstance(value, datetime):
        return value.isoformat()

    if isinstance(value, float):
        if math.isnan(value) or math.isinf(value):
            return None
        return value

    if isinstance(value, list):
        return [clean_value(v) for v in value]

    if isinstance(value, dict):
        return {
            str(k).replace("$", "").replace(".", "_"): clean_value(v)
            for k, v in value.items()
        }

    return value

with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    for doc in collection.find().limit(LIMIT):
        clean_doc = clean_value(doc)

        line = json.dumps(
            clean_doc,
            ensure_ascii=False,
            allow_nan=False,
            default=str
        )

        f.write(line + "\n")

print(f"Exported to {OUTPUT_FILE}")