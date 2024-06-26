# Gada Electronics Online Retail Store

This project is an online retail store for Gada Electronics, allowing customers to browse and purchase electronic products.
It includes modules for customers to sign up, view products, manage addresses, add items to the cart, and complete purchases.
Additionally, there's a warehouse manager module for managing product inventory and vieing the product analytics.

## File Structure

```
web/
│
├── templates/
|   ├── account.html
|   ├── add_product.html
|   ├── addresses.html
|   ├── adminbase.html
|   ├── base.html
|   ├── cart.html
|   ├── category.html
|   ├── checkout.html
|   ├── create_product.html
|   ├── error.html
|   ├── footer.html
|   ├── home.html
|   ├── login.html
|   ├── navbar.html
|   ├── order_history.html
|   ├── product_detail.html
|   ├── products.html
|   ├── receipt_failed.html
|   ├── receipt.html
|   ├── register.html
|   ├── signup.html
|   ├── warehouse_analytics.html
|   ├── warehouse_inventory.html
|   ├── warehouse_login.html
│
├── app.py
|
├── config.json
|
├── requirements.txt
```

- **templates/**: Contains all the HTML files for the user interface.
- **app.py**: Contains the entire backend code for the project.
- **config.json**: Contains the database connection details.
- **requirements.txt**: Contains all the dependencies for the project.

## How to Run

1. **Install dependencies**:
    ```bash
    pip install -r requirements.txt
    ```

1. **Database Setup**:
   - Create a MySQL database and import `database.sql` to set up tables and initial data.

2. **Backend Configuration**:
   - Update database connection details in `web/config.json`.

3. **Run the Application**:
   - Open a terminal in the project directory.
   - Start the Flask server:

     ```bash
     cd web/
     python app.py
     ```

4. **Access the Application**:
   - Open a web browser and go to `http://localhost:5000` to access the application.

## License

This repository is licensed under the [MIT License](LICENSE).

## Contributors

- [Vikranth Udandarao](https://github.com/Vikranth3140)
- [Tharun Harish](https://github.com/Tharun-Ninja)
- [Hemanth Dindigallu](https://github.com/hemanthdindigallu)
- [Aditya Prasad](https://github.com/adi1705tuktuk)