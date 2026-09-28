"""
PhishShield MongoDB Atlas Initialization & Seeding Script
Creates collections, indexes, and seeds initial threat telemetry documents.
"""

import os
import sys
from datetime import datetime, timedelta
from pathlib import Path
from dotenv import load_dotenv
from pymongo import MongoClient, ASCENDING, DESCENDING
from pymongo.errors import ServerSelectionTimeoutError, PyMongoError

# Load environment variables
load_dotenv(Path(__file__).resolve().parent / ".env")

MONGODB_URI = os.getenv("MONGODB_URI")
MONGODB_DATABASE = os.getenv("MONGODB_DATABASE", "phishshield")

# Initial seed data for telemetry collection
SAMPLE_RECORDS = [
    {
        "scan_id": "PS-E9A284F1",
        "url": "https:......al.com",
        "input_type": "url",
        "platform": "pc_extension",
        "verdict": "MALICIOUS",
        "confidence": 0.94,
        "device_id": "extension-chrome-01",
        "nickname": "Chrome Security Agent",
        "avatar_id": "radar",
        "timestamp": datetime.utcnow() - timedelta(minutes=45),
        "synced": True,
        "details": {
            "engine": "heuristics + nlp",
            "threat": "Brand spoofing & credential harvesting",
            "tld_suspicious": False,
        }
    },
    {
        "scan_id": "PS-83B410D6",
        "url": "https:......ix.com",
        "input_type": "url",
        "platform": "mobile_app",
        "verdict": "SUSPICIOUS",
        "confidence": 0.58,
        "device_id": "mobile-android-pixel",
        "nickname": "Parth's Phone",
        "avatar_id": "mobile",
        "timestamp": datetime.utcnow() - timedelta(hours=2),
        "synced": True,
        "details": {
            "engine": "heuristics",
            "threat": "Typosquatting detected",
            "tld_suspicious": True,
        }
    },
    {
        "scan_id": "PS-19DF48A2",
        "url": "https:......le.com",
        "input_type": "url",
        "platform": "mobile_app",
        "verdict": "SAFE",
        "confidence": 0.05,
        "device_id": "mobile-android-pixel",
        "nickname": "Parth's Phone",
        "avatar_id": "mobile",
        "timestamp": datetime.utcnow() - timedelta(hours=5),
        "synced": True,
        "details": {
            "engine": "heuristics",
            "threat": "None",
            "tld_suspicious": False,
        }
    },
    {
        "scan_id": "PS-3A79E220",
        "url": "Urgent......action",
        "input_type": "text",
        "platform": "mobile_app",
        "verdict": "MALICIOUS",
        "confidence": 0.88,
        "device_id": "mobile-android-pixel",
        "nickname": "Parth's Phone",
        "avatar_id": "mobile",
        "timestamp": datetime.utcnow() - timedelta(days=1),
        "synced": True,
        "details": {
            "engine": "nlp",
            "threat": "SMS phishing / smishing urgency pattern",
            "keywords": ["urgent", "account", "suspended", "verify"],
        }
    },
    {
        "scan_id": "PS-902D4E17",
        "url": "https:......ub.com",
        "input_type": "url",
        "platform": "pc_extension",
        "verdict": "SAFE",
        "confidence": 0.02,
        "device_id": "extension-chrome-01",
        "nickname": "Chrome Security Agent",
        "avatar_id": "radar",
        "timestamp": datetime.utcnow() - timedelta(days=1, hours=3),
        "synced": True,
        "details": {
            "engine": "heuristics",
            "threat": "None",
            "tld_suspicious": False,
        }
    }
]


def init_and_seed_atlas():
    if not MONGODB_URI:
        print("[!] ERROR: MONGODB_URI not found in .env file.")
        sys.exit(1)

    print(f"[*] Connecting to MongoDB Atlas database: '{MONGODB_DATABASE}'...")
    try:
        client = MongoClient(MONGODB_URI, serverSelectionTimeoutMS=8000)
        # Verify connection
        client.admin.command("ping")
        print("[+] SUCCESS: Connected to MongoDB Atlas Cluster!\n")
    except ServerSelectionTimeoutError as e:
        print("\n[!] Connection Error (ServerSelectionTimeoutError):")
        print("    Atlas dropped or timed out the connection.")
        print("    -> Most common cause: Your current IP address is not whitelisted in Atlas Network Access.")
        print("    -> Fix: Go to MongoDB Atlas (cloud.mongodb.com) -> Network Access -> Add IP Address -> Allow Access from Anywhere (0.0.0.0/0) or Add Current IP.")
        print(f"\n    Raw error: {e}")
        return False
    except Exception as e:
        print(f"\n[!] Connection Failed: {e}")
        return False

    db = client[MONGODB_DATABASE]

    # 1. Collection: scan_telemetry
    collection_name = "scan_telemetry"
    print(f"[*] Setting up collection '{collection_name}'...")
    telemetry_col = db[collection_name]

    # Create indexes
    print("    - Creating index on 'scan_id' (unique)...")
    telemetry_col.create_index("scan_id", unique=True)
    print("    - Creating index on 'timestamp' (descending)...")
    telemetry_col.create_index([("timestamp", DESCENDING)])
    print("    - Creating index on 'device_id'...")
    telemetry_col.create_index("device_id")
    print("    - Creating index on 'verdict'...")
    telemetry_col.create_index("verdict")

    # Seed initial documents
    print("\n[*] Seeding initial threat telemetry records...")
    inserted_count = 0
    for record in SAMPLE_RECORDS:
        try:
            telemetry_col.update_one(
                {"scan_id": record["scan_id"]},
                {"$setOnInsert": record},
                upsert=True
            )
            inserted_count += 1
            print(f"    [+] Seeded record: {record['scan_id']} | {record['verdict']} | {record['url']}")
        except PyMongoError as err:
            print(f"    [-] Failed to insert {record['scan_id']}: {err}")

    # 2. Total count check
    total_docs = telemetry_col.count_documents({})
    print(f"\n[+] Total documents in '{collection_name}': {total_docs}")

    # 3. List all collections in database
    all_collections = db.list_collection_names()
    print(f"[+] Active collections in '{MONGODB_DATABASE}': {all_collections}")
    print("\n[+] Database setup and seeding completed successfully!")
    client.close()
    return True



if __name__ == "__main__":
    init_and_seed_atlas()
