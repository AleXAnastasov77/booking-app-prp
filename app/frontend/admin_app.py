import os
import uuid
from datetime import datetime

import msal

from flask import Flask, redirect, render_template, request, url_for
from werkzeug.security import check_password_hash, generate_password_hash
from dotenv import load_dotenv

load_dotenv()
app = Flask(__name__, static_folder="staticEmployees", template_folder="templatesEmployees")


CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SECRET = os.getenv("CLIENT_SECRET")
AUTHORITY = os.getenv("AUTHORITY")
REDIRECT_PATH = "/getAToken"
SCOPE = ["User.Read"]


@app.route("/login")
def login():
    # Redirect user to Microsoft login
    msal_app = msal.ConfidentialClientApplication(
        CLIENT_ID, authority=AUTHORITY, client_credential=CLIENT_SECRET
    )
    auth_url = msal_app.get_authorization_request_url(
        SCOPE,
        redirect_uri=url_for("authorized", _external=True)
    )
    return redirect(auth_url)

@app.route(REDIRECT_PATH)
def authorized():
    # Handle redirect from Microsoft
    code = request.args.get('code')
    if not code:
        return "No code provided", 400

    msal_app = msal.ConfidentialClientApplication(
        CLIENT_ID, authority=AUTHORITY, client_credential=CLIENT_SECRET
    )
    result = msal_app.acquire_token_by_authorization_code(
        code,
        scopes=SCOPE,
        redirect_uri=url_for("authorized", _external=True)
    )
    if "id_token_claims" in result:
        # You can access user info here, e.g.:
        #user_email = result["id_token_claims"].get("preferred_username")
        # Store user info in session, etc.     
        return redirect(url_for("index"))
    else:
        return "Login failed", 400

@app.route('/')
def index():
    return render_template('menu.html')

@app.route('/create-user', methods=['GET', 'POST'])
def create_user():
    return render_template('create_user.html')

@app.route('/users')
def users():
    # Fetch all users from the database


    return render_template('users.html', users)

@app.route('/edit-user/<int:user_id>', methods=['GET', 'POST'])
def edit_user(user_id):


    return render_template('edit_user.html')

@app.route('/delete-user/<int:user_id>')
def delete_user(user_id):

    return redirect(url_for('users'))

@app.route('/bookings')
def bookings():


    return render_template('bookings.html', bookings)


@app.route('/create-booking', methods=['GET', 'POST'])
def create_booking():
    if request.method == 'POST':

        return redirect(url_for('bookings'))

    return render_template('create_booking.html')


if __name__ == '__main__':
    app.run(debug=True,host='0.0.0.0', port=5001)  # Change host and port as needed
