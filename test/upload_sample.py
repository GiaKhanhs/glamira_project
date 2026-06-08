from google.cloud import storage

client = storage.Client()

bucket = client.bucket("glamira_data_lake")

blob = bucket.blob("raw/summary/test100.jsonl")

blob.upload_from_filename("test100.jsonl")