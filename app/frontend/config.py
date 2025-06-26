import configparser
import os
from dotenv import load_dotenv

load_dotenv()

API_KEY=os.getenv("API_KEY")

CONFIG = configparser.ConfigParser()
CONFIG.read("config.ini")

CONFIG["api"]["url"] = os.getenv("API_URL")

def get_headers():
    headers = {
        "X-API-KEY": os.getenv("API_KEY")
    }
    return headers

def get_secret_key():
    secret_key = os.getenv("SECRET_KEY")
    return secret_key