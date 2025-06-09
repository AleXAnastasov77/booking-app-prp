from dotenv import load_dotenv
import os
from mysql.connector import pooling
from pathlib import Path
import tempfile
import requests
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from config import CONFIG

load_dotenv()

try:
    key_vault_url = CONFIG['key_vault']['url']
    username_secret_name = os.getenv("DB_USERNAME_SECRET")
    password_secret_name = os.getenv("DB_PASSWORD_SECRET")

    if key_vault_url and username_secret_name and password_secret_name:
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
except Exception as e:
    print(f"[WARNING] Failed to load secrets from Azure: {e}")
    print("[INFO] Falling back to local .env values.")
    db_user = os.getenv("DB_USERNAME")
    db_password = os.getenv("DB_PASSWORD")
    ca_cert_path = None  # or a local cert path


# Always define connection_pool
connection_pool = pooling.MySQLConnectionPool(
    pool_name="mypool",
    pool_size=5,
    pool_reset_session=True,
    host=os.getenv("DATABASE_HOST_AZURE"),
    port=int(os.getenv("DATABASE_PORT", 3306)),
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
