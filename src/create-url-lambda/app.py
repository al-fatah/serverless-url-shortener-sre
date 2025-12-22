import os, json, boto3
from string import ascii_letters, digits
from random import choice, randint
from time import strftime, time
from urllib import parse

APP_URL = os.getenv("APP_URL")             # e.g. https://group1-urlshortener.example.com/
MIN_CHAR = int(os.getenv("MIN_CHAR", "12"))
MAX_CHAR = int(os.getenv("MAX_CHAR", "16"))
REGION_AWS = os.getenv("REGION_AWS")
DB_NAME = os.getenv("DB_NAME")

ddb = boto3.resource("dynamodb", region_name=REGION_AWS).Table(DB_NAME)
ALPHABET = ascii_letters + digits

def generate_timestamp():
    return strftime("%Y-%m-%dT%H:%M:%S")

def expiry_date():
    return int(time()) + 604800  # 7 days

def check_id(short_id: str) -> str:
    if "Item" in ddb.get_item(Key={"short_id": short_id}):
        return generate_id()
    return short_id

def generate_id():
    short_id = "".join(choice(ALPHABET) for _ in range(randint(MIN_CHAR, MAX_CHAR)))
    return check_id(short_id)

def lambda_handler(event, context):
    short_id = generate_id()
    long_url = json.loads(event.get("body") or "{}").get("long_url")

    if not long_url:
        return {"statusCode": 400, "body": "Missing long_url"}

    short_url = f"{APP_URL}{short_id}"
    analytics = {}

    headers = event.get("headers") or {}
    analytics["user_agent"] = headers.get("User-Agent")
    analytics["source_ip"] = headers.get("X-Forwarded-For")
    analytics["xray_trace_id"] = headers.get("X-Amzn-Trace-Id")

    # Store query params from long_url (optional analytics)
    if len(parse.urlsplit(long_url).query) > 0:
        url_params = dict(parse.parse_qsl(parse.urlsplit(long_url).query))
        analytics.update(url_params)

    ddb.put_item(Item={
        "short_id": short_id,
        "created_at": generate_timestamp(),
        "ttl": int(expiry_date()),
        "short_url": short_url,
        "long_url": long_url,
        "analytics": analytics,
        "hits": 0
    })

    return {"statusCode": 200, "body": short_url}
