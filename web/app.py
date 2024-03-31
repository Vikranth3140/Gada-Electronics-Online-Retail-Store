from flask import Flask, render_template, request, redirect
import bcrypt
import mysql.connector
import random
import string
import json
import os

application = app = Flask(__name__)

basedir = os.path.abspath(os.path.dirname(__file__))
config_path = os.path.join(basedir, 'config.json')

def mysql_connection():
    with open(config_path, "r") as file:
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

@app.route('/signup', methods=['GET','POST'])
def register():
    if request.method == 'GET':
        return render_template('signup.html')
    
    if request.method == 'POST':
        print(request.form)
        name = request.form['name']
        email = request.form['email']
        phone = request.form['phone']
        password = request.form['password']
        confirm_password = request.form['confirm-password']
        
        print('got herer')
        
        if password != confirm_password:
            # If passwords do not match, redirect back to signup page
            flash('Passwords do not match!')
            return redirect(url_for('signup'))
        
        password = encrypt_password(password).decode()
        Customer_ID = generate_customer_id()
        
        conn = mysql_connection()
        cursor = conn.cursor()
        cursor.execute("INSERT INTO Customer (Customer_ID, Name, Email, PhoneNo, Password) VALUES (%s, %s, %s, %s, %s)", (Customer_ID, name, email, phone, password))
        conn.commit()
        
        return redirect('/')
    
@app.route('/login', methods=['GET','POST'])
def login():
    if request.method == 'GET':
        return render_template('login.html')
    
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        
        conn = mysql_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Customer WHERE Email = %s", (email,))
        user = cursor.fetchone()
        
        if user and bcrypt.checkpw(password.encode(), user[4].encode()):
            return "Logged in successfully!"
        else:
            return "Invalid email or password"
        
@app.route('/admin/login', methods=['GET','POST'])
def adminLogin():
    if request.method == 'GET':
        return render_template('login.html')
    
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        
        conn = mysql_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Customer WHERE Email = %s", (email,))
        user = cursor.fetchone()
        
        if user and bcrypt.checkpw(password.encode(), user[4].encode()):
            return "Logged in successfully!"
        else:
            return "Invalid email or password"
     
@app.route('/products/create', methods=['GET'])
def create_product():
    return render_template('create_product.html')


@app.route('/products', methods=['GET','POST'])
def add_product():
    if request.method == 'GET':
        # Execute MySQL query to fetch all products
        conn = mysql_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Product")
        products = cursor.fetchall()

        # Pass the data to the products.html template
        return render_template('products.html', products=products)
    
    if request.method == 'POST':
        product_name = request.form['product_name']
        manufacturer = request.form['manufacturer']
        price = request.form['price']
        description = request.form['description']
        quantity = request.form['quantity']
        discount = request.form['discount']

        # Execute MySQL query to insert product data
        conn = mysql_connection()
        cursor = conn.cursor()
        query = "INSERT INTO Product (Manufacturer, Name, Price, Description, Quantity, Discount) VALUES (%s, %s, %s, %s, %s, %s)"
        values = (manufacturer, product_name, price, description, quantity, discount)
        cursor.execute(query, values)
        conn.commit()

        cursor.close()
        conn.close()
        return "Product added successfully!"
    
@app.route('/products/<product_id>')
def product_detail(product_id):
    conn = mysql_connection()
    cursor = conn.cursor(dictionary=True)

    # Fetch the specific product by ID
    query = "SELECT * FROM Product WHERE Product_ID = %s"
    cursor.execute(query, (product_id,))

    product = cursor.fetchone()  # Assuming Product_ID is unique, fetchone() is appropriate

    cursor.close()
    conn.close()

    # Check if the product exists before rendering
    if product:
        return render_template('product_detail.html', product=product)
    else:
        return "Product not found", 404



@app.route('/category/<category_name>')
def category(category_name):
    conn = mysql_connection()
    cursor = conn.cursor(dictionary=True)

    # Use parameterized queries to prevent SQL injection
    query = "SELECT Product_ID, Manufacturer, Name, Price, ImgURL, Description, Quantity, Discount FROM Product WHERE Category = %s"
    cursor.execute(query, (category_name,))

    # Fetch all products in the category
    products = cursor.fetchall()
    print(products)

    cursor.close()
    conn.close()

    # Render a template with the fetched products
    return render_template('category.html', products=products, category_name=category_name)


@app.route('/cart/<card_id>', methods=['GET','POST'])
def cart(card_id):
    if request.method == 'GET':
        return render_template('cart.html', cart_id=card_id)
    
@app.route('/account', methods=['GET','POST'])
def account():
    if request.method == 'GET':
        return render_template('account.html')
    
    if request.method == 'POST':
        return "Account updated successfully!"

@app.route('/checkout', methods=['GET','POST'])
def checkout():
    if request.method == 'GET':
        return render_template('checkout.html')
    
    if request.method == 'POST':
        card_id = request.form['card_id']
        address = request.form['address']
        phone = request.form['phone']
        email = request.form['email']
        
        conn = mysql_connection()
        cursor = conn.cursor()
        cursor.execute("INSERT INTO Orders (Card_ID, Address, Phone, Email) VALUES (%s, %s, %s, %s)", (card_id, address, phone, email))
        conn.commit()
        
        return "Order placed successfully!"


@app.route('/')
def index():
    conn = mysql_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT Category, CategoryURL FROM Categories")
    categories = cursor.fetchall()  # This will be a list of tuples [(category_name, category_url), ...]
    cursor.close()
    conn.close()
    # You might want to convert this into a list of dictionaries for easier handling in the template
    categories_dict = [{'name': category[0], 'url': category[1]} for category in categories]
    return render_template('home.html', categories=categories_dict)


if __name__ == '__main__':
    app.run()