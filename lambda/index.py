import json
import urllib.parse
import boto3
import os
import logging
from decimal import Decimal

# Initialize AWS SDK clients
s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

# Set up logging for CloudWatch
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Fetch table name from environment or standard project default
TABLE_NAME = os.environ.get('DYNAMODB_TABLE', 'project3-table')

def lambda_handler(event, context):
    try:
        # Get bucket name and file key from the S3 event trigger
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
        
        logger.info(f"Processing file {key} from bucket {bucket}")

        # Fetch the uploaded file from S3
        response = s3.get_object(Bucket=bucket, Key=key)
        file_content = response['Body'].read().decode('utf-8')
        
        # parse_float=Decimal ensures all floats in JSON are converted to DynamoDB-compatible Decimals
        data = json.loads(file_content, parse_float=Decimal)

        # Parse and write to DynamoDB
        table = dynamodb.Table(TABLE_NAME)
        
        # Handle single record or list of records
        records = data if isinstance(data, list) else [data]
        
        for record in records:
            if 'transaction_id' in record and 'timestamp' in record:
                table.put_item(Item=record)
                logger.info(f"Successfully inserted transaction: {record['transaction_id']}")
            else:
                logger.warning(f"Skipping record missing transaction_id or timestamp: {record}")

        return {
            'statusCode': 200,
            'body': json.dumps('Data processed successfully!')
        }

    except Exception as e:
        logger.error(f"Error processing file {key} from bucket {bucket}: {str(e)}")
        raise e