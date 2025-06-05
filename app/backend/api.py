from flask import Flask, request, jsonify, session
from db import get_connection, get_dict_cursor
import uuid
import datetime
import bcrypt
from dotenv import load_dotenv
import os
from functools import wraps


load_dotenv()
API_KEY = os.getenv("API_KEY")

def api_key_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        key = request.headers.get("X-API-KEY")
        if not key or key != API_KEY:
            return jsonify({"error": "Invalid or missing API Key"}), 401
        return f(*args, **kwargs)
    return decorated_function


def post_register():
    data = request.json
    if not data.get("email") or not data.get("password"):
        return {"error": "Missing email or password"}, 400

    user_id = str(uuid.uuid4())
    conn, cursor = get_dict_cursor()
    try:
        hashed_pw = bcrypt.hashpw(data["password"].encode('utf-8'), bcrypt.gensalt())
        cursor.execute("""
            INSERT INTO user (user_id, email, hashed_password, role, first_name, last_name, phone_number)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (user_id, data["email"], hashed_pw, "customer", data["first_name"], data["last_name"], data["phone_number"]))
        conn.commit()
        return {"userId": user_id}, 201
    finally:
        cursor.close()
        conn.close()



@api_key_required  
def post_login():
    data = request.json
    conn, cursor = get_dict_cursor()
    try:
        cursor.execute("SELECT * FROM user WHERE email = %s", (data["email"],))
        user = cursor.fetchone()

        if not user or not bcrypt.checkpw(
            data["password"].encode("utf-8"),
            user["hashed_password"].encode("utf-8")
        ):
            return {"error": "Bad credentials"}, 401

        session["user_id"] = user["user_id"]
        session["email"] = user["email"]
        session["role"] = user["role"]
        return {"message": "Login successful", "user_id": user["user_id"]}, 200
    finally:
        cursor.close()
        conn.close()


def get_me():
    data = request.args
    user_id = data.get("user_id")

    if not user_id:
        return jsonify({"error": "Missing user_id parameter"}), 400

    conn, cursor = get_dict_cursor()
    try:

        cursor.execute("SELECT user_id, email, role, first_name, last_name, phone_number FROM user WHERE user_id = %s", (user_id,))
        user = cursor.fetchone()

        if not user:
            return jsonify({"error": "User not found"}), 404

        cursor.execute("SELECT * FROM booking WHERE user_id = %s", (user_id,))
        bookings = cursor.fetchall()

        return jsonify({
            "user": {
                "id": user["user_id"],
                "email": user["email"],
                "role": user["role"],
                "first_name": user["first_name"],
                "last_name": user["last_name"],
                "phone_number": user["phone_number"]
            },
            "bookings": [{
                "id": b["booking_id"],
                "accommodationId": b["accommodation_id"],
                "booking_date": b["booking_date"],
                "check_in": b["check_in_date"],
                "check_out": b["check_out_date"]
            } for b in bookings]
        })
    finally:
        cursor.close()
        conn.close()




def post_root():
    data = request.json
    booking_id = str(uuid.uuid4())
    conn, cursor = get_dict_cursor()
    try:
        cursor.execute("""
            INSERT INTO booking (id, user_id, accommodation_id, date)
            VALUES (%s, %s, %s, %s)
        """, (booking_id, session["user_id"], data["accommodationId"], data["date"]))
        conn.commit()
        return {"bookingId": booking_id}, 201
    finally:
        cursor.close()
        conn.close()



def delete_id(id):
    conn, cursor = get_dict_cursor()
    try:
        cursor.execute("SELECT * FROM booking WHERE id = %s", (id,))
        booking = cursor.fetchone()
        if not booking or booking["user_id"] != session["user_id"]:
            return {"error": "Not your booking"}, 403
        cursor.execute("DELETE FROM booking WHERE id = %s", (id,))
        conn.commit()
        return {"message": "Booking canceled"}
    finally:
        cursor.close()
        conn.close()



def get_parking():
    conn, cursor = get_dict_cursor()
    try:
        cursor.execute("SELECT * FROM accommodation")
        accommodations = cursor.fetchall()
        return jsonify([{
            "id": a["id"], "name": a["name"], "location": a["location"]
        } for a in accommodations])
    finally:
        cursor.close()
        conn.close()



def delete_parking_id(id):
    conn, cursor = get_dict_cursor()
    try:
        cursor.execute("SELECT * FROM booking WHERE id = %s", (id,))
        booking = cursor.fetchone()
        if not booking or booking["user_id"] != session["user_id"]:
            return {"error": "Not your reservation"}, 403
        cursor.execute("DELETE FROM booking WHERE id = %s", (id,))
        conn.commit()
        return {"message": "Parking reservation canceled"}
    finally:
        cursor.close()
        conn.close()
