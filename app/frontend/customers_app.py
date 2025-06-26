from flask import Flask, render_template, request, session, redirect, url_for
from functools import wraps
import requests
from config import CONFIG, get_headers, get_secret_key

import logging

app = Flask(__name__, static_folder="staticCustomers", template_folder="templatesCustomers")
app.secret_key = get_secret_key()

API_URL = CONFIG["api"]["url"]


def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

@app.route('/')
def home():
    return render_template('index.html')
@app.route('/login', methods = ['GET', 'POST'])
def login():
    if request.method == "GET":
        return render_template('login.html')
    else:
        email = request.form.get("email")
        password = request.form.get("password")
        payload = {"email":email, "password":password}
        response = requests.post(f"{API_URL}/login", headers=get_headers(), json=payload)
        if response.status_code == 200:
            data = response.json()
            user_id = data.get("user_id")
            if user_id:
                session[user_id] = user_id
                return render_template("index.html")
            else:
                return render_template("login.html", message="Login failed: no user id returned.")
        else:
            return render_template("login.html", message = "Invalid credentials.")
@app.route('/accomodation.nl')
def accomodation_nl():
    return render_template('accomodation.nl.html')

@app.route('/accomodation.bl')
def accomodation_bl():
    return render_template('accomodation.bl.html')

@app.route('/accomodation.gm')
def accomodation_gm():
    return render_template('accomodation.gm.html')

@app.route('/facilities')
def facilities():
    return render_template('facilities.html')

@app.route('/food')
def food():
    return render_template('foodandbev.html')

@app.route('/info')
def info():
    return render_template('info.html')

@app.route('/booking')
def booking():
    return render_template('booking.html')

@app.route('/reserve_table')
def reserve_table():
    return render_template('restaurant-reservation.html')


if __name__ == '__main__':
    app.run(debug=True)