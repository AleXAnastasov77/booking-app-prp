from dotenv import load_dotenv
import os
from mysql.connector import pooling
from pathlib import Path
import tempfile
import requests
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from config import CONFIG
import logging
import traceback

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
logger = logging.getLogger(__name__)

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
        db_host = CONFIG["azure_db"]["host"]

        ca_url = "https://dl.cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem"
        response = requests.get(ca_url)
        response.raise_for_status()

        with tempfile.NamedTemporaryFile(delete=False, suffix=".crt.pem") as tmp_ca:
            tmp_ca.write(response.content)
            ca_cert_path = tmp_ca.name
except Exception as e:
    logger.error("[ERROR] Failed to load secrets from Azure Key Vault.")
    logger.error(f"Exception type: {type(e).__name__}")
    logger.error(f"Exception message: {e}")
    logger.debug("Full traceback:\n" + traceback.format_exc())

    print(f"[ERROR] Key Vault access failed: {e}")

    db_user = os.getenv("DB_USERNAME")
    db_password = os.getenv("DB_PASSWORD")
    db_host = os.getenv("DATABASE_HOST") or CONFIG["azure_db"]["host"]
    ca_cert_path = None

# Always define connection_pool
connection_pool = pooling.MySQLConnectionPool(
    pool_name="mypool",
    pool_size=5,
    pool_reset_session=True,
    host=db_host,
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
