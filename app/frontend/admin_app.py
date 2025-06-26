import os
import uuid
from datetime import datetime
import msal
import requests
from config import CONFIG
from flask import Flask, redirect, render_template, request, url_for, jsonify, session


app = Flask(__name__, static_folder="staticEmployees", template_folder="templatesEmployees")
app.secret_key = os.getenv("SECRET_KEY")


CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SECRET = os.getenv("CLIENT_SECRET")
AUTHORITY = os.getenv("AUTHORITY")
REDIRECT_PATH = "/getAToken"
SCOPE = ["User.Read"]

# === Backend base URL ===
BACKEND_URL = f"{CONFIG["api"]["url"]}/admin/"


@app.route("/login")
def login():
    msal_app = msal.ConfidentialClientApplication(
        CLIENT_ID,
        authority=AUTHORITY,
        client_credential=CLIENT_SECRET
    )
    auth_url = msal_app.get_authorization_request_url(
        SCOPE,
        redirect_uri=url_for("authorized", _external=True)
    )
    return redirect(auth_url)


@app.route(REDIRECT_PATH)
def authorized():
    code = request.args.get('code')
    if not code:
        return "No code provided", 400

    msal_app = msal.ConfidentialClientApplication(
        CLIENT_ID,
        authority=AUTHORITY,
        client_credential=CLIENT_SECRET
    )
    result = msal_app.acquire_token_by_authorization_code(
        code,
        scopes=SCOPE,
        redirect_uri=url_for("authorized", _external=True)
    )

    print("MSAL Result:", result)

    if "id_token_claims" in result:
        session["user"] = result["id_token_claims"]
        return redirect(url_for("index"))
    else:
        return f"Login failed: {result.get('error_description', 'Unknown error')}", 400


@app.route("/logout")
def logout():
    session.clear()
    return redirect("/")


@app.route('/')
def index():
    return render_template('menu.html')


@app.route('/create-user', methods=['GET', 'POST'])
def create_user():
    if request.method == 'POST':
        data = {
            "name": request.form['name'],
            "email": request.form['email'],
            "phone_number": request.form['phone_number'],
            "password": request.form['password'],
            "role": request.form['role']
        }
        response = requests.post(f"{BACKEND_URL}/users", json=data)
        if response.status_code == 201:
            return redirect(url_for('users'))
        else:
            return f"Error: {response.text}", response.status_code

    return render_template('create_user.html')


@app.route('/users')
def users():
    response = requests.get(f"{BACKEND_URL}/users")
    if response.status_code == 200:
        users = response.json()
        return render_template('users.html', users=users)
    return f"Error fetching users: {response.text}", response.status_code


@app.route('/edit-user/<string:user_id>', methods=['GET', 'POST'])
def edit_user(user_id):
    if request.method == 'POST':
        data = {
            "email": request.form['email'],
            "phone_number": request.form['phone_number'],
            "hashed_password": request.form['password'],
            "role": request.form['role']
        }
        response = requests.put(f"{BACKEND_URL}/users/{user_id}", json=data)
        return redirect(url_for('users'))

    response = requests.get(f"{BACKEND_URL}/users/{user_id}")
    if response.status_code == 200:
        user = response.json()
        return render_template('edit_user.html', user=user)
    return f"Error fetching user: {response.text}", response.status_code


@app.route('/delete-user/<string:user_id>')
def delete_user(user_id):
    response = requests.delete(f"{BACKEND_URL}/users/{user_id}")
    return redirect(url_for('users'))


@app.route('/bookings')
def bookings():
    response = requests.get(f"{BACKEND_URL}/bookings")
    if response.status_code == 200:
        bookings = response.json()
        return render_template('bookings.html', bookings=bookings)
    return f"Error fetching bookings: {response.text}", response.status_code


@app.route('/create-booking', methods=['GET', 'POST'])
def create_booking():
    if request.method == 'POST':
        data = {
            "userId": request.form['user_id'],
            "accommodationId": request.form['accommodation_id'],
            "date": request.form['date']
        }
        response = requests.post(f"{BACKEND_URL}/bookings", json=data)
        return redirect(url_for('bookings'))
    return render_template('create_booking.html')


@app.route('/edit-booking/<string:booking_id>', methods=['GET', 'POST'])
def edit_booking(booking_id):
    if request.method == 'POST':
        data = {
            "userId": request.form['user_id'],
            "accommodationId": request.form['accommodation_id'],
            "checkInDate": request.form['check_in_date'],
            "checkOutDate": request.form['check_out_date']
        }
        response = requests.put(f"{BACKEND_URL}/bookings/{booking_id}", json=data)
        return redirect(url_for('bookings'))

    response = requests.get(f"{BACKEND_URL}/bookings/{booking_id}")
    if response.status_code == 200:
        booking = response.json()
        return render_template('edit_booking.html', booking=booking)
    return f"Error fetching booking: {response.text}", response.status_code


@app.route('/delete-booking/<string:booking_id>')
def delete_booking(booking_id):
    response = requests.delete(f"{BACKEND_URL}/bookings/{booking_id}")
    return redirect(url_for('bookings'))


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5002)
