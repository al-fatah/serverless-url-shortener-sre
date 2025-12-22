import os
import json
import types

import app


class FakeTable:
    def __init__(self):
        self.items = {}

    def get_item(self, Key):
        sid = Key["short_id"]
        if sid in self.items:
            return {"Item": self.items[sid]}
        return {}

    def put_item(self, Item):
        self.items[Item["short_id"]] = Item
        return {"ResponseMetadata": {"HTTPStatusCode": 200}}


def test_missing_long_url(monkeypatch):
    monkeypatch.setenv("APP_URL", "https://example.com")
    monkeypatch.setenv("REGION_AWS", "us-east-1")
    monkeypatch.setenv("DB_NAME", "test-table")

    # Patch ddb table
    app.ddb = FakeTable()

    resp = app.lambda_handler({"body": json.dumps({})}, types.SimpleNamespace())
    assert resp["statusCode"] == 400


def test_creates_short_url(monkeypatch):
    monkeypatch.setenv("APP_URL", "https://example.com")
    monkeypatch.setenv("REGION_AWS", "us-east-1")
    monkeypatch.setenv("DB_NAME", "test-table")

    app.ddb = FakeTable()

    event = {"body": json.dumps({"long_url": "https://openai.com"})}
    resp = app.lambda_handler(event, types.SimpleNamespace())
    assert resp["statusCode"] == 200

    body = json.loads(resp["body"])
    assert "short_url" in body
    assert body["short_url"].startswith("https://example.com/")
