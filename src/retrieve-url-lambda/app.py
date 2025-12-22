import json
import os
import boto3

REGION_AWS = os.getenv("REGION_AWS")
DB_NAME = os.getenv("DB_NAME")

ddb = boto3.resource("dynamodb", region_name=REGION_AWS).Table(DB_NAME)


def _response(status: int, body: dict | str, extra_headers: dict | None = None):
    if isinstance(body, dict):
        body = json.dumps(body)

    headers = {"Content-Type": "application/json"}
    if extra_headers:
        headers.update(extra_headers)

    return {"statusCode": status, "headers": headers, "body": body}


def lambda_handler(event, context):
    """
    Expected event shape (from API Gateway mapping template):
      {
        "short_id": "abc123"
      }
    Activity notes: "You need to pass the short_id into the Lambda"
    and then return a redirect (302) with Location header. :contentReference[oaicite:1]{index=1}
    """
    if not REGION_AWS or not DB_NAME:
        return _response(500, {"error": "Missing required env vars: REGION_AWS, DB_NAME"})

    short_id = event.get("short_id")
    if not short_id:
        return _response(400, {"error": "short_id missing"})

    try:
        resp = ddb.get_item(Key={"short_id": short_id})
        item = resp.get("Item")
        if not item or "long_url" not in item:
            return _response(404, {"error": "short_id not found"})

        long_url = item["long_url"]

        # Increment hit counter
        ddb.update_item(
            Key={"short_id": short_id},
            UpdateExpression="SET hits = if_not_exists(hits, :zero) + :inc",
            ExpressionAttributeValues={":inc": 1, ":zero": 0},
        )

        # Return 302 redirect with Location header
        return _response(302, {"redirect": long_url}, extra_headers={"Location": long_url})

    except Exception:
        # Keep error message generic (avoid leaking internals)
        return _response(400, {"error": "short_id or url invalid in request"})
