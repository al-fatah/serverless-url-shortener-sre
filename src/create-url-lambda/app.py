import json
import os
from random import choice, randint
from string import ascii_letters, digits
from time import strftime, time
from urllib import parse

import boto3


APP_URL = os.getenv("APP_URL")  # e.g. https://group1-urlshortener.example.com/
REGION_AWS = os.getenv("REGION_AWS")
DB_NAME = os.getenv("DB_NAME")

MIN_CHAR = int(os.getenv("MIN_CHAR", "12"))
MAX_CHAR = int(os.getenv("MAX_CHAR", "16"))

ALPHABET = ascii_letters + digits

ddb = boto3.resource("dynamodb", region_name=REGION_AWS).Table(DB_NAME)


def now_iso() -> str:
    return strftime("%Y-%m-%dT%H:%M:%S")


def expiry_epoch() -> int:
    # 7 days
    return int(time()) + 604800


def _response(status: int, body: dict | str):
    if isinstance(body, dict):
        body = json.dumps(body)
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": body,
    }


def _get_body(event: dict) -> dict:
    raw = event.get("body")
    if not raw:
        return {}
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        return {}


def _headers(event: dict) -> dict:
    return event.get("headers") or {}


def _generate_id() -> str:
    return "".join(choice(ALPHABET) for _ in range(randint(MIN_CHAR, MAX_CHAR)))


def _id_exists(short_id: str) -> bool:
    resp = ddb.get_item(Key={"short_id": short_id})
    return "Item" in resp


def generate_unique_id(max_attempts: int = 5) -> str:
    for _ in range(max_attempts):
        sid = _generate_id()
        if not _id_exists(sid):
            return sid
    # extremely unlikely, but safe fallback
    return _generate_id()


def extract_analytics(event: dict, long_url: str) -> dict:
    h = _headers(event)
    analytics: dict = {
        "user_agent": h.get("User-Agent") or h.get("user-agent"),
        "source_ip": h.get("X-Forwarded-For") or h.get("x-forwarded-for"),
        "xray_trace_id": h.get("X-Amzn-Trace-Id") or h.get("x-amzn-trace-id"),
    }

    # If long_url has query params, store them (optional)
    query = parse.urlsplit(long_url).query
    if query:
        analytics.update(dict(parse.parse_qsl(query)))
    return analytics


def lambda_handler(event, context):
    if not APP_URL or not REGION_AWS or not DB_NAME:
        return _response(
            500,
            {"error": "Missing required env vars: APP_URL, REGION_AWS, DB_NAME"},
        )

    body = _get_body(event)
    long_url = body.get("long_url")

    if not long_url:
        return _response(400, {"error": "Missing 'long_url' in request body"})

    # Basic sanity check (keep it simple; API validation can be added later)
    if not (long_url.startswith("http://") or long_url.startswith("https://")):
        return _response(400, {"error": "long_url must start with http:// or https://"})

    short_id = generate_unique_id()
    short_url = f"{APP_URL.rstrip('/')}/{short_id}"

    item = {
        "short_id": short_id,
        "created_at": now_iso(),
        "ttl": expiry_epoch(),
        "short_url": short_url,
        "long_url": long_url,
        "analytics": extract_analytics(event, long_url),
        "hits": 0,
    }

    ddb.put_item(Item=item)

    # Activity expects to return the short URL string; we return JSON (better for APIs).
    # Your API Gateway can still return plain text later if you want.
    return _response(200, {"short_url": short_url})
