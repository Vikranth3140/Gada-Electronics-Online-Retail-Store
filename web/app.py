from flask import Flask, render_template, request, redirect
import bcrypt
import mysql.connector
import random
import string
import json

app = Flask(__name__)

def mysql_connection():
    with open("config.json", "r") as file:
        data = json.load(file)

    conn = mysql.connector.connect(
        host=data['host'],
        user=data['user'],
        password=data['password'],
        database=data['database']
    )
    return conn

def encrypt_password(password):
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt(rounds=15))

def generate_customer_id(length=6):
    characters = "".join(set(string.ascii_letters.upper())) + string.digits
    return ''.join(random.choice(characters).capitalize() for _ in range(length))


@app.route('/customer')
def customer():
    return render_template('register.html')


@app.route('/register', methods=['POST'])
def register():
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        phone = request.form['phone']
        password = request.form['password']
        
        password = encrypt_password(password).decode()
        Customer_ID = generate_customer_id()
        
        conn = mysql_connection()
        cursor = conn.cursor()
        cursor.execute("INSERT INTO Customer (Customer_ID, Name, Email, PhoneNo, Password) VALUES (%s, %s, %s, %s, %s)", (Customer_ID, name, email, phone, password))
        conn.commit()
        
        return redirect('/')
        
     

@app.route('/')
def index():
    return "registered successfully!"
        

if __name__ == '__main__':
    app.run()