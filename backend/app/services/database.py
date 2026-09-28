import asyncio
import logging
import os
from datetime import datetime
from pathlib import Path
from typing import Any

import certifi
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorCollection
from pymongo.errors import PyMongoError

load_dotenv(Path(__file__).resolve().parents[3] / ".env")

logger = logging.getLogger(__name__)


class DatabaseService:
    def __init__(self) -> None:
        self.uri = os.getenv("MONGODB_URI")
        self.database_name = os.getenv("MONGODB_DATABASE", "phishshield")
        self.client: AsyncIOMotorClient | None = None
        self.collection: AsyncIOMotorCollection | None = None
        self.connected = False

    async def connect(self) -> None:
        if not self.uri:
            logger.warning("MONGODB_URI is not configured; using in-memory telemetry only")
            return
        self.client = AsyncIOMotorClient(
            self.uri,
            tlsCAFile=certifi.where(),
            serverSelectionTimeoutMS=5000,
            connectTimeoutMS=5000,
            socketTimeoutMS=5000,
        )
        try:
            await asyncio.wait_for(self.client.admin.command("ping"), timeout=6)
            database = self.client[self.database_name]
            self.collection = database["scan_telemetry"]
            await self.collection.create_index("scan_id", unique=True)
            await self.collection.create_index("timestamp")
            await self.collection.create_index("device_id")
            self.connected = True
            logger.info("Connected to MongoDB database '%s'", self.database_name)
        except (PyMongoError, asyncio.TimeoutError):
            self.client.close()
            self.client = None
            self.collection = None
            logger.exception("MongoDB connection failed")
            raise

    async def close(self) -> None:
        if self.client:
            self.client.close()
        self.client = None
        self.collection = None
        self.connected = False

    async def insert_telemetry(self, event: dict[str, Any]) -> bool:
        if self.collection is None:
            return False
        document = dict(event)
        document["timestamp"] = datetime.utcnow()
        document["synced"] = True
        try:
            await self.collection.insert_one(document)
            return True
        except PyMongoError:
            logger.exception("Failed to persist scan telemetry")
            return False

    async def get_recent_telemetry(
        self, limit: int = 20, device_id: str | None = None
    ) -> list[dict[str, Any]]:
        if self.collection is None:
            return []
        try:
            query = {"device_id": device_id} if device_id else {}
            cursor = self.collection.find(query, {"_id": 0}).sort("timestamp", -1).limit(limit)
            return await cursor.to_list(length=limit)
        except PyMongoError:
            logger.exception("Failed to read scan telemetry")
            return []


database_service = DatabaseService()
