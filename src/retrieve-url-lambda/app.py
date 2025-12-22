import os, boto3

REGION_AWS = os.getenv("REGION_AWS")
DB_NAME = os.getenv("DB_NAME")
ddb = boto3.resource("dynamodb", region_name=REGION_AWS).Table(DB_NAME)

def lambda_handler(event, context):
    short_id = event.get("short_id")

    if not short_id:
        return {"statusCode": 400, "body": "short_id missing"}

    try:
        item = ddb.get_item(Key={"short_id": short_id})
        long_url = item["Item"]["long_url"]

        ddb.update_item(
            Key={"short_id": short_id},
            UpdateExpression="set hits = hits + :val",
            ExpressionAttributeValues={":val": 1}
        )
    except Exception:
        return {"statusCode": 400, "body": "short_id or url invalid in request."}

    # API Gateway will map this to Location header
    return {"statusCode": 302, "location": long_url}
