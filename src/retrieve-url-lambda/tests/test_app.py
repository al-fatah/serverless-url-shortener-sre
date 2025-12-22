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

    def update_item(self, Key, UpdateExpression, ExpressionAttributeValues):
        sid = Key["short_id"]
        if sid not in self.items:
            raise KeyError("not found")
        self.items[sid]["hits"] = self.items[sid].get("hits", 0) + 1
        return {"ResponseMetadata": {"HTTPStatusCode": 200}}


def test_missing_short_id(monkeypatch):
    monkeypatch.setenv("REGION_AWS", "us-east-1")
    monkeypatch.setenv("DB_NAME", "test-table")
    app.ddb = FakeTable()

    resp = app.lambda_handler({}, types.SimpleNamespace())
    assert resp["statusCode"] == 400


def test_not_found(monkeypatch):
    monkeypatch.setenv("REGION_AWS", "us-east-1")
    monkeypatch.setenv("DB_NAME", "test-table")
    app.ddb = FakeTable()

    resp = app.lambda_handler({"short_id": "nope"}, types.SimpleNamespace())
    assert resp["statusCode"] == 404


def test_redirect_and_increment(monkeypatch):
    monkeypatch.setenv("REGION_AWS", "us-east-1")
    monkeypatch.setenv("DB_NAME", "test-table")
    table = FakeTable()
    table.items["abc123"] = {"short_id": "abc123", "long_url": "https://openai.com", "hits": 0}
    app.ddb = table

    resp = app.lambda_handler({"short_id": "abc123"}, types.SimpleNamespace())
    assert resp["statusCode"] == 302
    assert resp["headers"]["Location"] == "https://openai.com"

    body = json.loads(resp["body"])
    assert body["redirect"] == "https://openai.com"
    assert table.items["abc123"]["hits"] == 1
