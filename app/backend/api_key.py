import os
from flask import request
from dotenv import load_dotenv

load_dotenv()

def get_api_key():
    return os.getenv("API_KEY")

def validate_api_key():
    key = request.headers.get("X-API-KEY")
    api_key = get_api_key()
    return key == api_key