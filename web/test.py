import mysql.connector
import bcrypt

def mysql_connection():
    conn = mysql.connector.connect(
        host='',
        user='',
        password='',
        database=''
    )
    return conn

# conn = mysql_connection()
# cursor = conn.cursor()
# cursor.execute("INSERT INTO Customer (Customer_ID, Name, Email, PhoneNo, Password) VALUES (%s, %s, %s, %s, %s)", ("et23est", "VickySticky", "VickySuerman@gmail.com", "1231231231", "admin"))
# conn.commit()

# # tables = cursor.fetchall()
# # print(tables)
# cursor.close()
# conn.close()


# def encrypt_password(password):
#     return bcrypt.hashpw(password.encode(), bcrypt.gensalt(rounds=15))
# p = encrypt_password("admin")
# print(p)
# print(p.decode()    )
# print(encrypt_password("admin"))


# import random
# import string

# def generate_customer_id(length=8):
#     characters = string.ascii_letters + string.digits
#     return ''.join(random.choice(characters) for _ in range(length))

# # Generate a random customer ID
# customer_id = generate_customer_id()
# print("Generated Customer ID:", customer_id)


