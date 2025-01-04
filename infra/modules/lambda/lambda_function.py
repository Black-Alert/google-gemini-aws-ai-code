import json

def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps({'body': 'Lambda Dummy code is working'})
    }
