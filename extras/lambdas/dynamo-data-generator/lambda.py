import uuid
import time
import boto3


def handler(event, context):
    print("Function started")
    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table("Terraform")
    table.put_item(Item=create_record())
    print("Function completed")


def create_record():
    record = {
        "id": str(uuid.uuid4()),
        "date": int(time.time()),
        "ttl": int(time.time()) + 3600
    }
    return record