import json
import asyncio
import os
from google import genai

client = genai.Client(api_key=os.getenv('GEMINI_API_KEY'), http_options={'api_version': 'v1alpha'})


async def process_chat(message: str) -> str:
    chat = client.aio.chats.create(model='gemini-2.0-flash-thinking-exp')
    response = await chat.send_message(message)
    return response.text


def lambda_handler(event, context):
    print(event)

    try:
        # Parse the body as JSON
        body = json.loads(event.get('body', '{}'))
        message = body.get('message', '')

        if not message:
            raise ValueError("Message not found in the request body.")

        print(message)

        # Process the chat message
        response_text = asyncio.run(process_chat(message))

        return {
            'statusCode': 200,
            'body': json.dumps({'response': response_text}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type'
            }
        }

    except (json.JSONDecodeError, ValueError) as e:
        # Handle JSON parsing errors or missing 'message' key
        return {
            'statusCode': 400,
            'body': json.dumps({'error': str(e)}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type'
            }
        }
    except Exception as e:
        # Handle other unexpected errors
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal server error', 'details': str(e)}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type'
            }
        }
