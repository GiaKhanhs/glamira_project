from pymongo import MongoClient

client = MongoClient("mongodb://localhost:27017/")

db = client["glamira"]

print("Collections:")
print(db.list_collection_names())

print("\nDocument count:")
print(db.summary.count_documents({}))

print("\nSample:")
print(db.summary.find_one())