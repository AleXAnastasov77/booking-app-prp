from dotenv import load_dotenv
import os
from mysql.connector import pooling
from pathlib import Path
import tempfile
import requests
from azure.identity import ManagedIdentityCredential
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from config import CONFIG

load_dotenv()

try:
    key_vault_url = CONFIG["key_vault"]["url"]
    username_secret_name = os.getenv("DB_USERNAME_SECRET")
    password_secret_name = os.getenv("DB_PASSWORD_SECRET")

    if key_vault_url and username_secret_name and password_secret_name:
        credential = None
        try:
            # Try managed identity
            client_id = os.getenv("AZURE_CLIENT_ID")
            if client_id:
                credential = ManagedIdentityCredential(client_id=client_id)
                credential.get_token("https://vault.azure.net/.default")
            else:
                raise ValueError("AZURE_CLIENT_ID not set for ManagedIdentityCredential.")
        except Exception as e:
            try:
                credential = DefaultAzureCredential()
                credential.get_token("https://vault.azure.net/.default")
            except Exception as inner:
                print("DefaultAzureCredential also failed.")
                raise inner

        # Proceed if credential was successfully created
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
    else:
        raise ValueError("Missing Key Vault URL or secret names.")
except Exception as e:
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
    database=CONFIG["azure_db"]["db_name"],
    ssl_ca=ca_cert_path
)

def get_connection():
    return connection_pool.get_connection()

def get_dict_cursor():
    conn = get_connection()
    return conn, conn.cursor(dictionary=True)
