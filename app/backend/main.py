import connexion
from config import CONFIG
from flask_cors import CORS

# Create the Connexion app
app = connexion.FlaskApp(__name__, specification_dir=".", options={"swagger_ui": True})

# Enable passing through Authorization header to Flask
app.add_api("admin-api.yaml", strict_validation=True, pass_context_arg_name='request')
app.add_api("user-api.yaml", strict_validation=True, pass_context_arg_name='request')

# Access the underlying Flask app
flask_app = app.app
flask_app.secret_key = CONFIG["api"]["secret_key"]

# Optional: expose Authorization in CORS
CORS(flask_app, expose_headers=["Authorization"])

if __name__ == "__main__":
    app.run(host=CONFIG["api"]["host"], port=CONFIG["api"]["port"], debug=CONFIG["api"]["debug"])
