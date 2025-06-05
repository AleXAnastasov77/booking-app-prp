from dotenv import load_dotenv
import os
from mysql.connector import pooling
from pathlib import Path
import requests
import tempfile
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient


# Explicitly specify the .env path relative to db.py
env_path = Path(__file__).resolve().parent / '.env'
load_dotenv(dotenv_path=env_path)

key_vault_url = os.getenv("KEY_VAULT_URL")
username_secret_name = os.getenv("DB_USERNAME_SECRET")
password_secret_name = os.getenv("DB_PASSWORD_SECRET")

credential = DefaultAzureCredential()
client = SecretClient(vault_url=key_vault_url, credential=credential)

db_user = client.get_secret(username_secret_name).value
db_password = client.get_secret(password_secret_name).value

ca_url = "https://dl.cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem"
response = requests.get(ca_url)
response.raise_for_status()

with tempfile.NamedTemporaryFile(delete=False, suffix=".crt.pem") as tmp_ca:
    tmp_ca.write(response.content)
    ca_cert_path = tmp_ca.name

# Initialize connection pool once
connection_pool = pooling.MySQLConnectionPool(
    pool_name="mypool",
    pool_size=5,
    pool_reset_session=True,
    host=os.getenv("DATABASE_HOST_AZURE"),
    port=os.getenv("DATABASE_PORT"),
    user=db_user,
    password=db_password,
    database=os.getenv("DATABASE_NAME"),
    ssl_ca=ca_cert_path
)

def get_connection():
    return connection_pool.get_connection()

def get_dict_cursor():
    conn = get_connection()
    return conn, conn.cursor(dictionary=True)
