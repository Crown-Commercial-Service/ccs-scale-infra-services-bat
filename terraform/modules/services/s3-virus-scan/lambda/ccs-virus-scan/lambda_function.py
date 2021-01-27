import urllib.parse as urlparse
import urllib.request as request
import json
import os


def lambda_handler(event, context):
    host = os.environ['HOST']
    for record in event["Records"]:
        key    = record["s3"]["object"]["key"]
        bucket = record["s3"]["bucket"]["name"]
        url    = host + "/scan?" + urlparse.urlencode({"key": key, "bucket": bucket})
        print("url: " + url)

        data = request.urlopen(url)

    return {
        'statusCode': 200,
        'body': json.dumps('OK')
    }
