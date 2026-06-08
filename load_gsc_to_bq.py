import os
import json
import time
from pathlib import Path

from google.cloud import bigquery
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR / ".env")

BQ_PROJECT = os.getenv("BQ_PROJECT")
BQ_DATASET = os.getenv("BQ_DATASET")
BQ_TABLE = os.getenv("BQ_TABLE")

GCS_BUCKET = os.getenv("GCS_BUCKET")
GCS_PREFIX = os.getenv("GCS_PREFIX")

required_envs = {
    "BQ_PROJECT": BQ_PROJECT,
    "BQ_DATASET": BQ_DATASET,
    "BQ_TABLE": BQ_TABLE,
    "GCS_BUCKET": GCS_BUCKET,
    "GCS_PREFIX": GCS_PREFIX,
}

missing = [key for key, value in required_envs.items() if not value]

if missing:
    raise ValueError(f"Missing environment variables: {missing}")


def main():
    start_time = time.time()

    fields = json.loads((BASE_DIR / "schema_fields.json").read_text())

    client = bigquery.Client(project=BQ_PROJECT)

    table_id = f"{BQ_PROJECT}.{BQ_DATASET}.{BQ_TABLE}"
    uri = f"gs://{GCS_BUCKET}/{GCS_PREFIX}/part_*.jsonl.gz"

    schema = [
        bigquery.SchemaField(field, "STRING", mode="NULLABLE")
        for field in fields
    ]

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.NEWLINE_DELIMITED_JSON,
        schema=schema,
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
        ignore_unknown_values=True,
        max_bad_records=1000,
    )

    print("========== BIGQUERY LOAD ==========")
    print(f"Source      : {uri}")
    print(f"Destination : {table_id}")
    print(f"Fields      : {len(fields)}")

    load_job = client.load_table_from_uri(
        uri,
        table_id,
        job_config=job_config,
    )

    print(f"Started Job : {load_job.job_id}")

    while not load_job.done():
        elapsed = time.time() - start_time

        print(
            f"[{time.strftime('%H:%M:%S')}] "
            f"Job running... "
            f"Elapsed: {elapsed / 60:.1f} min"
        )

        time.sleep(10)
        load_job.reload()

    load_job.result()

    elapsed = time.time() - start_time
    table = client.get_table(table_id)

    print("\n========== DONE ==========")
    print(f"Job State   : {load_job.state}")
    print(f"Rows Loaded : {table.num_rows:,}")
    print(f"Time        : {elapsed / 60:.2f} min")
    print(f"Table       : {table_id}")

    if load_job.errors:
        print("\nErrors:")
        print(load_job.errors)


if __name__ == "__main__":
    main()