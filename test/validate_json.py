# validate_json_strict.py
import json
import math

file_path = "summary_sample_100k_bq_safe.jsonl"

def reject_constant(x):
    raise ValueError(f"Invalid JSON constant: {x}")

bad = 0

with open(file_path, "r", encoding="utf-8") as f:
    for i, line in enumerate(f, start=1):
        try:
            json.loads(line, parse_constant=reject_constant)
        except Exception as e:
            print("Bad line:", i)
            print("Error:", e)
            print(line[:1000])
            bad += 1
            if bad >= 5:
                break

print("Bad lines:", bad)