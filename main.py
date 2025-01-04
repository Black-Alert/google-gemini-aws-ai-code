import asyncio
import os

from google import genai
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

client = genai.Client(api_key=os.getenv('GEMINI_API_KEY'), http_options={'api_version': 'v1alpha'})


async def process_chat(message: str) -> str:
    chat = client.aio.chats.create(model='gemini-2.0-flash-thinking-exp')
    response = await chat.send_message(message)
    return response.text


def lambda_handler(event, context):
    message = event.get('message', 'Hello')
    response_text = asyncio.run(process_chat(message))
    return {
        'statusCode': 200,
        'body': response_text,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type'
        }
    }


if __name__ == "__main__":
    test_event = {
        'message': 'Tell me about our solar system!'
    }
    test_context = {}  # You can add more context information if needed
    result = lambda_handler(test_event, test_context)
    print(result['body'])
