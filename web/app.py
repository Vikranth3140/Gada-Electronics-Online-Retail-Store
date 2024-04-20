from flask import Flask, render_template, request, redirect, url_for, flash, session
import bcrypt
import mysql.connector
import random
import string
import json
import os

app = Flask(__name__)
app.secret_key = 'your_secret_key'

basedir = os.path.abspath(os.path.dirname(__file__))
config_path = os.path.join(basedir, 'config.json')

ALLOWED_ROUTES_WITHOUT_ADDRESS = ['login', 'signup', 'select_address', 'logout','addresses', 'static']


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

def insert_new_cart_and_payment(cursor, cart_id, customer_id):
    """Inserts a new cart and pending payment into the database."""
    # cursor.execute("INSERT INTO Cart (Cart_ID, Customer_ID) VALUES (%s, %s)", (cart_id, customer_id))
    cursor.execute("INSERT INTO Payment (Payment_ID, Customer_ID, Cart_ID, Status) VALUES (%s, %s, %s, 'Pending')", 
                   ('PAY' + ''.join(random.choices(string.ascii_uppercase + string.digits, k=10)), customer_id, cart_id))

def find_nearest_warehouse(customer_address_id):
    conn = mysql_connection()
    cursor = conn.cursor(dictionary=True)

    # Get the customer's pin code
    cursor.execute("SELECT Pincode FROM Address WHERE Address_ID = %s", (customer_address_id,))
    customer_result = cursor.fetchone()
    if not customer_result:  # Check if the address exists
        return None
    customer_pincode = customer_result['Pincode']

    # Fetch all distinct warehouse pin codes
    cursor.execute("SELECT DISTINCT Pincode FROM Warehouse")
    warehouses = cursor.fetchall()

    if not warehouses:  # Check if there are any warehouses
        return None

    # Find the nearest warehouse based on pin code difference
    try:
        nearest_warehouse_pin = min(warehouses, key=lambda x: abs(int(x['Pincode']) - int(customer_pincode)))['Pincode']
    except ValueError:  # Catch the ValueError if warehouses is empty
        cursor.close()
        conn.close()
        return None

    cursor.close()
    conn.close()

    # Return the pin code of the nearest warehouse
    return nearest_warehouse_pin


# @app.before_request
# def require_address():
#     # Check if the session's selected_address_id is not set
#     if not session.get('selected_address_id'):
#         # Get the endpoint of the current request
#         endpoint = request.endpoint
        
#         # Check if the endpoint is not in the allowed list
#         if endpoint and endpoint not in ALLOWED_ROUTES_WITHOUT_ADDRESS:
#             flash('Please select an address to continue.', 'warning')
#             return redirect(url_for('addresses'))
        
# Signup Route
@app.route('/signup', methods=['GET', 'POST'])
def register():
    
    if 'customer_id' in session:
        return redirect(url_for('index'))
    
    if request.method == 'GET':
        return render_template('signup.html')

    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        phone = request.form['phone']
        password = request.form['password']
        confirm_password = request.form['confirm-password']

        if password != confirm_password:
            flash('Passwords do not match!', 'error')
            return redirect(url_for('register'))

        password = encrypt_password(password).decode()
        Customer_ID = generate_customer_id()

        conn = mysql_connection()
        cursor = conn.cursor()
        cursor.execute("INSERT INTO Customer (Customer_ID, Name, Email, PhoneNo, Password) VALUES (%s, %s, %s, %s, %s)",
                       (Customer_ID, name, email, phone, password))
        
        
        new_cart_id = generate_cart_id()
        # Insert new cart and pending payment entry
        insert_new_cart_and_payment(cursor, new_cart_id, Customer_ID)
      
        conn.commit()
        cursor.close()
        conn.close()
        
        session['customer_id'] = Customer_ID
        session['cart_id'] = new_cart_id
        session['cart_count'] = 0
        session['cart'] = {}
        

        flash('Registration successful!', 'success')
        return redirect(url_for('index'))

# Login Route 
@app.route('/login', methods=['GET', 'POST'])
def login():
    if 'customer_id' in session:
        return redirect(url_for('index'))
    
    if request.method == 'GET':
        return render_template('login.html')

    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']

        conn = mysql_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM Customer WHERE Email = %s", (email,))
        user = cursor.fetchone()

        if user and bcrypt.checkpw(password.encode(), user['Password'].encode()):
            session['customer_id'] = user['Customer_ID']
            
            if user['Current_Address_ID']:
                session['selected_address_id'] = user['Current_Address_ID']
                nearest_warehouse_id = find_nearest_warehouse(session['selected_address_id'])
                session['nearest_warehouse_id'] = nearest_warehouse_id
                
            else:
                # Redirect to addresses page if no address is selected
                return redirect(url_for('addresses'))
            
            
            
            # Check for pending payments
            cursor.execute("SELECT Cart_ID FROM Payment WHERE Customer_ID = %s AND Status = 'Pending'", (user['Customer_ID'],))
            payment = cursor.fetchone()

            if payment:
                # Set session variables for existing pending cart
                session['cart_id'] = payment['Cart_ID']
                # Retrieve the user's cart items
                cursor.execute("""
                    SELECT Product_ID, SUM(Quantity) AS Quantity 
                    FROM Cart 
                    WHERE Customer_ID = %s 
                    GROUP BY Product_ID
                """, (user['Customer_ID'],))
                cart_items = cursor.fetchall()

                # If there are items in the cart, populate the session cart
                if cart_items:
                    session_cart = {item['Product_ID']: item['Quantity'] for item in cart_items}
                    session['cart'] = session_cart
                    session['cart_count'] = sum(item['Quantity'] for item in cart_items)
                else:
                    # If there are no items, ensure the session cart is empty
                    session['cart'] = {}
                    session['cart_count'] = 0
            else:
                # No pending payment, create a new cart
                new_cart_id = generate_cart_id()
                # Insert new cart and pending payment entry
                insert_new_cart_and_payment(cursor, new_cart_id, user['Customer_ID'])
                session['cart_id'] = new_cart_id
                session['cart_count'] = 0

            conn.commit()
            cursor.close()
            conn.close()
            return redirect(url_for('index'))
        else:
            cursor.close()
            conn.close()
            flash('Invalid email or password', 'error')
            return redirect(url_for('login'))

# Logout Route
@app.route('/logout')
def logout():
    if 'customer_id' in session:
        session.clear()
        
    return redirect(url_for('index'))

# Forgot Password Route
@app.route('/forgot-password', methods=['GET', 'POST'])
def forgot_password():
    if request.method == 'GET':
        return render_template('forgot_password.html')

    if request.method == 'POST':
        email = request.form['email']

        conn = mysql_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT Customer_ID, Name, Email FROM Customer WHERE Email = %s", (email,))
        user_data = cursor.fetchone()
        cursor.close()
        conn.close()

        if user_data:
            # Generate and send a password reset token to the user's email
            user = User(user_data[0], user_data[1], user_data[2], None)
            token = generate_password_reset_token(user.email)
            send_password_reset_email(user.email, token)
            flash('Password reset instructions have been sent to your email.', 'success')
            return redirect(url_for('login'))
        else:
            flash('Email not found. Please try again.', 'error')
            return redirect(url_for('forgot_password'))

# Password Reset Route
@app.route('/reset-password/<token>', methods=['GET', 'POST'])
def reset_password(token):
    if request.method == 'GET':
        try:
            email = verify_password_reset_token(token)
        except Exception as e:
            flash('Invalid or expired token.', 'error')
            return redirect(url_for('forgot_password'))

        return render_template('reset_password.html', token=token)

    if request.method == 'POST':
        password = request.form['password']
        confirm_password = request.form['confirm-password']

        if password != confirm_password:
            flash('Passwords do not match!', 'error')
            return redirect(url_for('reset_password', token=token))

        try:
            email = verify_password_reset_token(token)
        except Exception as e:
            flash('Invalid or expired token.', 'error')
            return redirect(url_for('forgot_password'))

        conn = mysql_connection()
        cursor = conn.cursor()
        password_hash = encrypt_password(password).decode()
        cursor.execute("UPDATE Customer SET Password = %s WHERE Email = %s", (password_hash, email))
        conn.commit()
        cursor.close()
        conn.close()

        flash('Your password has been reset successfully.', 'success')
        return redirect(url_for('login'))

# Helper functions for password reset tokens
def generate_password_reset_token(email):
    serializer = Serializer(app.secret_key, expires_in=3600)  # Token expires in 1 hour
    return serializer.dumps({'email': email}).decode('utf-8')

def verify_password_reset_token(token):
    serializer = Serializer(app.secret_key)
    try:
        email = serializer.loads(token.encode('utf-8'))['email']
    except Exception as e:
        raise e
    return email

def send_password_reset_email(email, token):
    # Implement your email sending logic here
    # You can use a third-party email service or SMTP server
    print(f"Password reset token for {email}: {token}")
    pass

# Product Creation Route
@app.route('/products/create', methods=['GET', 'POST'])
def create_product():
    if request.method == 'GET':
        return render_template('create_product.html')

    if request.method == 'POST':
        product_name = request.form['product_name']
        manufacturer = request.form['manufacturer']
        price = request.form['price']
        description = request.form['description']
        quantity = request.form['quantity']
        discount = request.form['discount']
        category = request.form['category']

        conn = mysql_connection()
        cursor = conn.cursor()

        # Check if the category exists in the Categories table
        cursor.execute("SELECT Category FROM Categories WHERE Category = %s", (category,))
        category_exists = cursor.fetchone()

        if not category_exists:
            # Insert the new category into the Categories table
            cursor.execute("INSERT INTO Categories (Category) VALUES (%s)", (category,))
            conn.commit()

        # Insert the product into the Product table
        query = "INSERT INTO Product (Manufacturer, Name, Price, Category, Description, Quantity, Discount) VALUES (%s, %s, %s, %s, %s, %s, %s)"
        values = (manufacturer, product_name, price, category, description, quantity, discount)
        cursor.execute(query, values)
        conn.commit()

        cursor.close()
        conn.close()

        flash('Product added successfully!', 'success')
        return redirect(url_for('products'))


# Product Detail Route
@app.route('/products/<product_id>')
def product_detail(product_id):
    conn = mysql_connection()
    cursor = conn.cursor(dictionary=True)

    # Fetch product details
    query_product = "SELECT * FROM Product WHERE Product_ID = %s"
    cursor.execute(query_product, (product_id,))
    product = cursor.fetchone()

    if product:
        # Fetch available quantity in the warehouse
        query_warehouse = """
        SELECT SUM(Warehouse_Quantity) AS available_quantity
        FROM Warehouse
        WHERE Product_ID = %s AND Pincode = %s
        GROUP BY Product_ID
        """
        cursor.execute(query_warehouse, (product_id, session['nearest_warehouse_id']))
        warehouse_info = cursor.fetchone()

        # Initialize available quantity
        available_quantity = warehouse_info['available_quantity'] if warehouse_info else 0

        # Subtract quantity in the cart session if exists
        if 'cart' in session and product_id in session['cart']:
            session_product_quantity = session['cart'][product_id]
            available_quantity -= session_product_quantity
        print("available_quantity",available_quantity)
        # Calculate the max addable quantity, ensuring it's not negative
        max_addable_quantity = max(0, min(10, available_quantity))
        print("max_addable_quantity",max_addable_quantity)

        cursor.close()
        conn.close()

        return render_template('product_detail.html', product=product, max_addable_quantity=max_addable_quantity)
    else:
        flash('Product not found', 'error')
        return redirect(url_for('index'))


def generate_cart_id(length=10):
    """Generates a unique Cart_ID with a given length plus the 'CART' prefix."""
    prefix = 'CART'
    digits = ''.join(random.choice(string.digits) for _ in range(length))
    cart_id = prefix + digits
    return cart_id


# Cart Route
@app.route('/cart/<cart_id>', methods=['GET', 'POST'])
def cart(cart_id):
    if('customer_id' not in session):
        return redirect(url_for('login'))
    
    if request.method == 'POST':
        action = request.form.get('action')
        print(request.form)

        if action == "remove":
            product_id = request.form['product_id']
            cart_id = session['cart_id']
            customer_id = session['customer_id']

            conn = mysql_connection()
            cursor = conn.cursor(dictionary=True)

            # Get the quantity of the product to be removed
            cursor.execute("""
                SELECT Quantity FROM Cart 
                WHERE Cart_ID = %s AND Product_ID = %s
            """, (cart_id, product_id))
            
            product = cursor.fetchone()
            
            if product:
                remove_quantity = int(product['Quantity'])

                # Delete the product from the Cart table
                query = "DELETE FROM Cart WHERE Customer_ID = %s AND Product_ID = %s"
                cursor.execute(query, (customer_id, product_id))
                conn.commit()

                # Check if the product exists in the session cart and adjust quantity
                if 'cart' in session and product_id in session['cart']:
                    # Decrease the quantity in session cart or remove if it becomes 0
                    session['cart'][product_id] -= remove_quantity

                    if session['cart'][product_id] <= 0:
                        del session['cart'][product_id]

                    # Adjust the total cart count in the session
                    print("session cart",session['cart'])
                    print("session cart 2",session['cart_count'])
                    session['cart_count'] = sum(session['cart'].values())

                    # Ensure the session modification is saved
                    session.modified = True

                cursor.close()
                conn.close()

                flash('Product removed from cart successfully!', 'success')
            else:
                flash('Product not found in cart.', 'error')

            return redirect(url_for('cart', cart_id=cart_id))

        elif action == 'add':
            product_id = request.form['product_id']
            add_quantity = int(request.form['quantity'])
            customer_id = session['customer_id']

            conn = mysql_connection()
            cursor = conn.cursor(dictionary=True)

            # Check if the product already exists in the user's cart
            cursor.execute("""
                SELECT Quantity FROM Cart 
                WHERE Cart_ID = %s AND Customer_ID = %s AND Product_ID = %s
            """, (cart_id, customer_id, product_id))
            existing_product = cursor.fetchone()

            # Fetch the product details for price and discount
            cursor.execute("SELECT Price, Discount FROM Product WHERE Product_ID = %s", (product_id,))
            product_data = cursor.fetchone()
            
            print(product_data)

            if product_data:
                price = product_data['Price']
                discount = product_data['Discount']
                offer = price * (1 - discount / 100)
                offer = min(offer, 99999999.99)  # Ensure offer doesn't exceed DECIMAL(10, 2) range

                if existing_product:
                    # Product exists in cart, so update the quantity
                    print("testtingngg",existing_product)
                    new_quantity = int(existing_product['Quantity']) + add_quantity
                    cursor.execute("""
                        UPDATE Cart SET Quantity = %s
                        WHERE Cart_ID = %s AND Customer_ID = %s AND Product_ID = %s
                    """, (new_quantity, cart_id, customer_id, product_id))
                else:
                    # Product does not exist in cart, so insert as new entry
                    cursor.execute("""
                        INSERT INTO Cart (Cart_ID, Customer_ID, Product_ID, Price, Offer, Quantity) 
                        VALUES (%s, %s, %s, %s, %s, %s)
                    """, (cart_id, customer_id, product_id, price, offer, add_quantity))

                conn.commit()
                cursor.close()
                conn.close()

                # Update session cart count and cart structure
                session['cart_count'] = session.get('cart_count', 0) + add_quantity
                session_cart = session.get('cart', {})
                session_cart[product_id] = session_cart.get(product_id, 0) + add_quantity
                session['cart'] = session_cart
                session.modified = True  # Ensure the session modification is saved

                flash('Product added to cart successfully!', 'success')
            else:
                flash('Product not found', 'error')

            return redirect(f'/cart/{cart_id}')
        
        else:
            flash('Invalid action', 'error')
            return redirect(f'/cart/{cart_id}')
    
    else:
        conn = mysql_connection()
        cursor = conn.cursor(dictionary=True)

        customer_id = session['customer_id']

        query = """
            SELECT p.Product_ID, p.Name, p.Description, c.Price, c.Offer, c.Quantity
            FROM Cart c
            JOIN Product p ON c.Product_ID = p.Product_ID
            WHERE c.Customer_ID = %s
        """
        cursor.execute(query, (customer_id,))
        cart_items = cursor.fetchall()


        cursor.close()
        conn.close()
        
        print(cart_items)

        return render_template('cart.html', cart_items=cart_items)

# Category Route
@app.route('/category/<category_name>')
def category(category_name):
    if 'selected_address_id' not in session:
        flash('Please select an address to continue.', 'warning')
        return redirect(url_for('addresses'))

    customer_address_id = session['selected_address_id']
    nearest_warehouse_pin = find_nearest_warehouse(customer_address_id)

    if not nearest_warehouse_pin:
        flash('No nearest warehouse found.', 'error')
        return redirect(url_for('index'))

    conn = mysql_connection()
    cursor = conn.cursor(dictionary=True)

    # Adjust the query to fetch products based on the nearest warehouse pin code
    query = """
    SELECT p.Product_ID, p.Manufacturer, p.Name, p.Price, p.ImgURL, p.Description, p.Discount, w.Warehouse_Quantity
    FROM Product p
    JOIN Warehouse w ON p.Product_ID = w.Product_ID
    WHERE p.Category = %s AND w.Pincode = %s
    """
    cursor.execute(query, (category_name, nearest_warehouse_pin))

    products = cursor.fetchall()

    cursor.close()
    conn.close()
    
    print(session['cart'])
    for product in products:
    
        session_reserved = session['cart'].get(product['Product_ID'], 0) if 'cart' in session else 0
        product['Adjusted_Quantity'] = max(product['Warehouse_Quantity'] - session_reserved, 0)
        
    return render_template('category.html', products=products, category_name=category_name)



@app.route('/account', methods=['GET','POST'])
def account():
    if request.method == 'GET':
        return render_template('account.html')
    
    if request.method == 'POST':
        return "Account updated successfully!"
    
    
def generate_address_id(length=20):
    """Generates a random string of letters and digits for Address_ID."""
    characters = string.ascii_letters + string.digits
    return ''.join(random.choice(characters) for i in range(length))

@app.route('/addresses', methods=['GET', 'POST'])
def addresses():
    if 'customer_id' not in session:
        return redirect(url_for('login'))
    
    customer_id = session['customer_id']

    if request.method == 'POST':
        # Extract form data
        street_name = request.form['street_name']
        flat_no = request.form['flat_no']
        city = request.form['city']
        state = request.form['state']
        pincode = request.form['pincode']

        # Generate a unique Address_ID
        address_id = generate_address_id()

        # Connect to the database and add the address
        conn = mysql_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO Address (Address_ID, Customer_ID, Street_Name, Flat_No, City, State, Pincode) 
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (address_id, customer_id, street_name, flat_no, city, state, pincode))

        conn.commit()
        cursor.close()
        conn.close()

        flash('Address added successfully!', 'success')
        return redirect(url_for('addresses'))

    # Retrieve existing addresses
    conn = mysql_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM Address WHERE Customer_ID = %s", (customer_id,))
    addresses = cursor.fetchall()
    cursor.close()
    conn.close()

    return render_template('addresses.html', addresses=addresses)


@app.route('/select_address', methods=['POST'])
def select_address():
    if 'customer_id' not in session:
        return redirect(url_for('login'))
    
    selected_address_id = request.form['selected_address']
    customer_id = session['customer_id']

    # Connect to the database
    conn = mysql_connection()
    cursor = conn.cursor()

    # Update the customer's current address
    cursor.execute("""
        UPDATE Customer
        SET Current_Address_ID = %s
        WHERE Customer_ID = %s
    """, (selected_address_id, customer_id))

    conn.commit()

    # Optionally, update the session to reflect the change
    session['selected_address_id'] = selected_address_id
    
    nearest_warehouse_id = find_nearest_warehouse(session['selected_address_id'])
    session['nearest_warehouse_id'] = nearest_warehouse_id

    cursor.close()
    conn.close()

    flash('Address selected successfully!', 'success')
    return redirect(url_for('index'))   # Or redirect to another page as appropriate



@app.route('/order_history')
def order_history():
    if 'customer_id' not in session:
        return redirect(url_for('login'))
    
    customer_id = session['customer_id']
    conn = mysql_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT o.Order_ID, o.Payment_ID, p.Status, p.Cart_ID
        FROM Orders o
        JOIN Payment p ON o.Payment_ID = p.Payment_ID
        WHERE o.Customer_ID = %s
    """, (customer_id,))
    orders = cursor.fetchall()
    cursor.close()
    conn.close()

    return render_template('order_history.html', orders=orders)


@app.route('/checkout', methods=['GET', 'POST'])
def checkout():
    if request.method == 'GET':
        if 'customer_id' not in session:
            return redirect(url_for('login'))

        customer_id = session['customer_id']
        conn = mysql_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT p.Name, c.Price, c.Quantity
            FROM Cart c
            JOIN Product p ON c.Product_ID = p.Product_ID
            WHERE c.Customer_ID = %s
        """, (customer_id,))
        cart_items = cursor.fetchall()
        total = sum(item['Price'] * item['Quantity'] for item in cart_items)
        cursor.close()
        conn.close()

        return render_template('checkout.html', cart_items=cart_items, total=total)

    elif request.method == 'POST':
        if 'customer_id' not in session or 'cart_id' not in session:
            flash('Session expired or invalid. Please login again.', 'error')
            return redirect(url_for('login'))

        customer_id = session['customer_id']
        cart_id = session['cart_id']

        conn = mysql_connection()
        cursor = conn.cursor(dictionary=True)

        try:
            conn.start_transaction()

            # Fetch cart items to update warehouse quantities
            cursor.execute("""
                SELECT c.Product_ID, c.Quantity, p.Price, p.Name, w.Pincode AS Warehouse_ID
                FROM Cart c
                JOIN Product p ON c.Product_ID = p.Product_ID
                JOIN Warehouse w ON p.Product_ID = w.Product_ID
                WHERE c.Cart_ID = %s AND c.Customer_ID = %s
            """, (cart_id, customer_id))
            cart_items = cursor.fetchall()
            total = sum(item['Quantity'] * item['Price'] for item in cart_items)

            for item in cart_items:
                cursor.execute("""
                    UPDATE Warehouse
                    SET Warehouse_Quantity = Warehouse_Quantity - %s
                    WHERE Product_ID = %s AND Pincode = %s
                """, (item['Quantity'], item['Product_ID'], item['Warehouse_ID']))

            # Update payment status
            cursor.execute("UPDATE Payment SET Status = 'Completed' WHERE Cart_ID = %s AND Customer_ID = %s", (cart_id, customer_id))
            cursor.execute("SELECT LAST_INSERT_ID() AS Last_ID")  # Simulate retrieval of last inserted Payment ID
            payment_info = cursor.fetchone()

            # Generate and log the order
            order_date = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            order_id = f"ORD{payment_info['Last_ID']}"
            cursor.execute("""
                INSERT INTO Orders (Order_ID, Customer_ID, Payment_ID)
                VALUES (%s, %s, %s)
            """, (order_id, customer_id, payment_info['Last_ID']))

            # Clear the cart
            cursor.execute("DELETE FROM Cart WHERE Cart_ID = %s AND Customer_ID = %s", (cart_id, customer_id))

            # Create a new cart
            new_cart_id = generate_cart_id()
            insert_new_cart_and_payment(cursor, new_cart_id, customer_id)

            session['cart_id'] = new_cart_id
            session['cart_count'] = 0

            conn.commit()
            flash('Order placed successfully!', 'success')

            return render_template('receipt.html', order_id=order_id, order_date=order_date,
                                   payment_method='Credit Card', total=total, cart_items=cart_items)

        except Exception as e:
            conn.rollback()
            flash('An error occurred during checkout. Please try again.', 'error')
            print(e)
        finally:
            cursor.close()
            conn.close()

        return redirect(url_for('checkout'))




# Home Route
@app.route('/')
def index():
    if 'customer_id' not in session:
        flash('You need to be logged in to access the home page.', 'info')
        return redirect(url_for('login'))
    
    print(session)
    
    conn = mysql_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT Category, CategoryURL FROM Categories")
    categories = cursor.fetchall()
    cursor.close()
    conn.close()

    categories_dict = [{'name': category[0], 'url': category[1]} for category in categories]
    return render_template('home.html', categories=categories_dict)


@app.route('/warehouse/inventory', methods=['GET', 'POST'])
def warehouse_inventory():
    conn = mysql_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT DISTINCT Pincode FROM Warehouse")
    warehouses = cursor.fetchall()
    selected_warehouse = request.form.get('warehouse_pincode')
    products = []
    if selected_warehouse:
        cursor.execute("SELECT * FROM Product JOIN Warehouse ON Product.Product_ID = Warehouse.Product_ID WHERE Warehouse.Pincode = %s", (selected_warehouse,))
        products = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('warehouse_inventory.html', warehouses=warehouses, products=products, selected_warehouse=selected_warehouse)

@app.route('/warehouse/add_product', methods=['GET', 'POST'])
def add_product_to_warehouse():
    if request.method == 'POST':
        # Extract form data
        product_details = {
            'Product_ID': request.form['product_id'],
            'Manufacturer': request.form['manufacturer'],
            'Name': request.form['name'],
            'Price': request.form['price'],
            'Category': request.form['category'],
            'ImgURL': request.form['imgurl'],
            'Description': request.form['description'],
            'Discount': request.form['discount'],
            'Pincode': request.form['pincode'],
            'Warehouse_Quantity': request.form['warehouse_quantity']
        }
        # Insert the new product into the Product table and Warehouse table
        conn = mysql_connection()
        cursor = conn.cursor()
        cursor.execute("INSERT INTO Product (Product_ID, Manufacturer, Name, Price, Category, ImgURL, Description, Discount) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
                       (product_details['Product_ID'], product_details['Manufacturer'], product_details['Name'], product_details['Price'], product_details['Category'], product_details['ImgURL'], product_details['Description'], product_details['Discount']))
        cursor.execute("INSERT INTO Warehouse (Pincode, Product_ID, Warehouse_Quantity) VALUES (%s, %s, %s)",
                       (product_details['Pincode'], product_details['Product_ID'], product_details['Warehouse_Quantity']))
        conn.commit()
        cursor.close()
        conn.close()
        flash('Product added successfully!')
        return redirect(url_for('add_product_to_warehouse'))
    
    # Get all pincodes for the form
    conn = mysql_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT DISTINCT Pincode FROM Warehouse")
    pincodes = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('add_product.html', pincodes=pincodes)


if __name__ == '__main__':
    app.run(debug=True)