from db import db
import uuid

class User(db.Model):
    __tablename__ = 'user'  # Specify the table name if it's different from the class name
    user_id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4())) # Use user_id instead of id
    email = db.Column(db.String(120), unique=True, nullable=False)
    hashed_password = db.Column(db.String(128), nullable=False)
    role = db.Column(db.String(20), nullable=False)
    name = db.Column(db.String(255), nullable=False)
    phone_number = db.Column(db.String(255), nullable=True)

class Accommodation(db.Model):
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = db.Column(db.String(120), nullable=False)
    location = db.Column(db.String(120), nullable=False)

class Booking(db.Model):
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String(36), db.ForeignKey('user.id'), nullable=False)
    accommodation_id = db.Column(db.String(36), db.ForeignKey('accommodation.id'), nullable=False)
    date = db.Column(db.String(10), nullable=False)
