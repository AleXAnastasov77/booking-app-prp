from flask import request, jsonify
from db import get_connection, get_dict_cursor
import uuid

# USERS
# GET /users
def get_users():
    conn, cursor = get_dict_cursor()
    try:
        cursor.execute("SELECT * FROM user")
        users = cursor.fetchall()
        return jsonify(users)
    finally:
        cursor.close()
        conn.close()

# POST /users
def post_users():
    data = request.json
    conn, cursor = get_dict_cursor()
    try:
        user_id = str(uuid.uuid4())
        cursor.execute("""
            INSERT INTO user (user_id, name, email, phone_number, hashed_password, role)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (user_id, data["name"], data["email"], data["phone_number"], data["hashed_password"], data["role"]))
        conn.commit()
        return {
            "id": user_id,
            "name": data["name"],
            "email": data["email"],
            "phone_number": data["phone_number"],
            "hashed_password": data["hashed_password"],
            "role": data["role"]
        }, 201
    finally:
        cursor.close()
        conn.close()

# PUT /users/{id}
def put_users_id(id):
    data = request.json
    conn, cursor = get_dict_cursor()
    try:
        cursor.execute("""
            UPDATE user SET email = %s, phone_number = %s, hashed_password = %s, role = %s
            WHERE user_id = %s
        """, (data["email"], data["phone_number"], data["hashed_password"], data["role"], id))
        conn.commit()
        return {"message": "User updated"}
    finally:
        cursor.close()
        conn.close()

# DELETE /users/{id}
def delete_users_id(id):
    conn, cursor = get_dict_cursor()
    try:
        cursor.execute("DELETE FROM user WHERE user_id = %s", (id,))
        conn.commit()
        return {"message": "User deleted", "uuid": id}
    finally:
        cursor.close()
        conn.close()

# ACCOMMODATIONS
def post_accommodations():
    data = request.json
    acc_id = str(uuid.uuid4())
    conn, cursor = get_dict_cursor()
    try:
        cursor.execute("""
            INSERT INTO accommodation (id, name, location)
            VALUES (%s, %s, %s)
        """, (acc_id, data["name"], data["location"]))
        conn.commit()
        return {"id": acc_id}, 201
    finally:
        cursor.close()
        conn.close()

def put_accommodations_id(id):
    data = request.json
    conn, cursor = get_dict_cursor()
    try:
        cursor.execute("""
            UPDATE accommodation SET name = %s, location = %s WHERE id = %s
        """, (data["name"], data["location"], id))
        conn.commit()
        return {"message": "Accommodation updated"}
    finally:
        cursor.close()
        conn.close()

def delete_accommodations_id(id):
    conn, cursor = get_dict_cursor()
    try:
        cursor.execute("DELETE FROM accommodation WHERE id = %s", (id,))
        conn.commit()
        return {"message": "Accommodation deleted"}
    finally:
        cursor.close()
        conn.close()

# BOOKINGS
def get_bookings():
    conn, cursor = get_dict_cursor()
    try:
        cursor.execute("SELECT * FROM booking")
        bookings = cursor.fetchall()
        return jsonify(bookings)
    finally:
        cursor.close()
        conn.close()

def put_bookings_id(id):
    data = request.json
    conn, cursor = get_dict_cursor()
    try:
        cursor.execute("""
            UPDATE booking SET user_id = %s, accommodation_id = %s, date = %s WHERE id = %s
        """, (data["userId"], data["accommodationId"], data["date"], id))
        conn.commit()
        return {"message": "Booking updated"}
    finally:
        cursor.close()
        conn.close()

def delete_bookings_id(id):
    conn, cursor = get_dict_cursor()
    try:
        cursor.execute("DELETE FROM booking WHERE id = %s", (id,))
        conn.commit()
        return {"message": "Booking canceled"}
    finally:
        cursor.close()
        conn.close()
