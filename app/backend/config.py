import configparser
import os
from dotenv import load_dotenv

load_dotenv()
 
SECRET_KEY=str(os.getenv("SECRET_KEY"))

CONFIG = configparser.ConfigParser()
CONFIG.read("config.ini")

CONFIG["api"]["secret_key"] = SECRET_KEY