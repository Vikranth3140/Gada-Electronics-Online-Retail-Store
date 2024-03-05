CREATE DATABASE gada_electronics;


USE gada_electronics;


DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Address;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Warehouse;
DROP TABLE IF EXISTS Warehouse_Manager;
DROP TABLE IF EXISTS Cart;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Orders;


CREATE TABLE Customer (
    Customer_ID VARCHAR(20) NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    PhoneNo VARCHAR(10) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    PRIMARY KEY (Customer_ID)
);


CREATE TABLE Address (
    Address_ID VARCHAR(20) NOT NULL,
    Customer_ID VARCHAR(20) NOT NULL,
    Street_Name VARCHAR(255) NOT NULL,
    Flat_No VARCHAR(255) NOT NULL,
    Street VARCHAR(255) GENERATED ALWAYS AS (CONCAT(Flat_No, ' ', Street_Name)) STORED,
    City VARCHAR(255) NOT NULL,
    State VARCHAR(10) NOT NULL,
    Pincode VARCHAR(20) NOT NULL,
    PRIMARY KEY (Address_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
);


CREATE TABLE Product (
    Product_ID VARCHAR(20) NOT NULL,
    Manufacturer VARCHAR(255) NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Description VARCHAR(1000) NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity >= 0),
    Discount DECIMAL(5, 2) NOT NULL CHECK (Discount >= 0 AND Discount <= 100),
    PRIMARY KEY (Product_ID)
);


CREATE TABLE Warehouse (
    Pincode VARCHAR(20) NOT NULL,
    Product_ID VARCHAR(20) NOT NULL,
    Warehouse_Quantity INT NOT NULL CHECK (Warehouse_Quantity >= 0),
    PRIMARY KEY (Pincode, Product_ID),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);


CREATE TABLE Warehouse_Manager (
    Manager_ID VARCHAR(20) NOT NULL,
    Username VARCHAR(255) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    PRIMARY KEY (Manager_ID)
);


CREATE TABLE Cart (
    Cart_ID VARCHAR(20) NOT NULL,
    Customer_ID VARCHAR(20) NOT NULL,
    Product_ID VARCHAR(20) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Offer DECIMAL(5, 2) NOT NULL CHECK (Offer >= 0 AND Offer <= 100),
    Quantity INT NOT NULL CHECK (Quantity > 0),
    PRIMARY KEY (Cart_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);


CREATE TABLE Payment (
    Payment_ID VARCHAR(20) NOT NULL,
    Customer_ID VARCHAR(20) NOT NULL,
    Cart_ID VARCHAR(20) NOT NULL,
    Status VARCHAR(255) NOT NULL,
    PRIMARY KEY (Payment_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    FOREIGN KEY (Cart_ID) REFERENCES Cart(Cart_ID)
    -- Optionally, add CHECK constraints for Status if there are specific allowed values
);


CREATE TABLE Orders (
    Order_ID VARCHAR(20) NOT NULL,
    Customer_ID VARCHAR(20) NOT NULL,
    Payment_ID VARCHAR(20) NOT NULL,
    PRIMARY KEY (Order_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    FOREIGN KEY (Payment_ID) REFERENCES Payment(Payment_ID)
);


SHOW TABLES;


INSERT INTO Customer (Customer_ID, Name, Email, PhoneNo, Password) VALUES
('CUST001', 'John Doe', 'johndoe@example.com', '1234567890', 'password123'),
('CUST002', 'Jane Smith', 'janesmith@example.com', '2345678901', 'password234'),
('CUST003', 'Michael Brown', 'michaelbrown@example.com', '3456789012', 'password345'),
('CUST004', 'Emily White', 'emilywhite@example.com', '4567890123', 'password456'),
('CUST005', 'Daniel Harris', 'danielharris@example.com', '5678901234', 'password567'),
('CUST006', 'Jessica Green', 'jessicagreen@example.com', '6789012345', 'password678'),
('CUST007', 'William Johnson', 'williamjohnson@example.com', '7890123456', 'password789'),
('CUST008', 'Olivia Martin', 'oliviamartin@example.com', '8901234567', 'password890'),
('CUST009', 'James Thompson', 'jamesthompson@example.com', '9012345678', 'password901'),
('CUST010', 'Sophia Taylor', 'sophiataylor@example.com', '0123456789', 'password012'),
('CUST011', 'Christopher Anderson', 'chrisanderson@example.com', '1234506789', 'pass12345'),
('CUST012', 'Isabella Rodriguez', 'isabellarodriguez@example.com', '2345607891', 'pass23456');


INSERT INTO Address (Address_ID, Customer_ID, Street_Name, Flat_No, City, State, Pincode) VALUES
('ADDR001', 'CUST001', 'MG Road', '101', 'Bengaluru', 'KA', '560001'),
('ADDR002', 'CUST002', 'Park Street', '202', 'Kolkata', 'WB', '700016'),
('ADDR003', 'CUST003', 'Connaught Place', '303', 'New Delhi', 'DL', '110001'),
('ADDR004', 'CUST004', 'Marine Drive', '404', 'Mumbai', 'MH', '400021'),
('ADDR005', 'CUST005', 'Boat Club Road', '505', 'Pune', 'MH', '411001'),
('ADDR006', 'CUST006', 'Adyar', '606', 'Chennai', 'TN', '600020'),
('ADDR007', 'CUST007', 'Banjara Hills', '707', 'Hyderabad', 'TS', '500034'),
('ADDR008', 'CUST008', 'Ashram Road', '808', 'Ahmedabad', 'GJ', '380009'),
('ADDR009', 'CUST009', 'Mall Road', '909', 'Amritsar', 'PB', '143001'),
('ADDR010', 'CUST010', 'Jubilee Hills', '1010', 'Hyderabad', 'TS', '500033'),
('ADDR011', 'CUST011', 'Bapu Nagar', '1111', 'Jaipur', 'RJ', '302015'),
('ADDR012', 'CUST012', 'Indiranagar', '1212', 'Bengaluru', 'KA', '560038');


INSERT INTO Product (Product_ID, Manufacturer, Name, Price, Description, Quantity, Discount) VALUES
('PROD001', 'TechGadgets', 'Smartphone', 999.99, 'Latest model with advanced features', 100, 10),
('PROD002', 'HomeTech', 'Smart TV', 1200.00, 'High definition smart TV with voice control', 50, 5),
('PROD003', 'SoundGenius', 'Bluetooth Speaker', 150.00, 'Portable high-quality sound', 200, 15),
('PROD004', 'CompWorld', 'Laptop', 1500.00, 'Lightweight, high performance for professionals', 75, 8),
('PROD005', 'KitchenPro', 'Microwave Oven', 250.00, 'Fast cooking with smart settings', 100, 12),
('PROD006', 'FitnessGear', 'Treadmill', 800.00, 'Compact design with multiple exercise modes', 30, 10),
('PROD007', 'GameMaster', 'Video Game Console', 300.00, 'Latest gaming console with VR capabilities', 150, 5),
('PROD008', 'OfficeTech', 'Printer', 200.00, 'High-speed, efficient document printing', 100, 10),
('PROD009', 'MobileTech', 'Tablet', 600.00, 'Lightweight and powerful for on-the-go use', 120, 7),
('PROD010', 'SoundGenius', 'Headphones', 100.00, 'Noise-cancelling, long battery life', 150, 10),
('PROD011', 'HomeComfort', 'Air Conditioner', 1000.00, 'Energy-efficient cooling and heating', 40, 5),
('PROD012', 'TechGadgets', 'Smart Watch', 250.00, 'Fitness tracking and notifications', 200, 20);


INSERT INTO Warehouse (Pincode, Product_ID, Warehouse_Quantity) VALUES
('62704', 'PROD001', 20),
('06830', 'PROD002', 15),
('53703', 'PROD003', 30),
('78701', 'PROD004', 25),
('02108', 'PROD005', 20),
('80202', 'PROD006', 10),
('98101', 'PROD007', 35),
('60601', 'PROD008', 20),
('94102', 'PROD009', 25),
('10001', 'PROD010', 30),
('90001', 'PROD011', 15),
('33101', 'PROD012', 40);


INSERT INTO Warehouse_Manager (Manager_ID, Username, Password) VALUES
('WM001', 'manager1', 'wm_password1');


INSERT INTO Cart (Cart_ID, Customer_ID, Product_ID, Price, Offer, Quantity) VALUES
('CART001', 'CUST001', 'PROD001', 999.99, 10, 1),
('CART002', 'CUST002', 'PROD002', 1200.00, 5, 1),
('CART003', 'CUST003', 'PROD003', 150.00, 15, 2),
('CART004', 'CUST004', 'PROD004', 1500.00, 8, 1),
('CART005', 'CUST005', 'PROD005', 250.00, 12, 1),
('CART006', 'CUST006', 'PROD006', 800.00, 10, 1),
('CART007', 'CUST007', 'PROD007', 300.00, 5, 2),
('CART008', 'CUST008', 'PROD008', 200.00, 10, 1),
('CART009', 'CUST009', 'PROD009', 600.00, 7, 1),
('CART010', 'CUST010', 'PROD010', 100.00, 10, 2),
('CART011', 'CUST011', 'PROD011', 1000.00, 5, 1),
('CART012', 'CUST012', 'PROD012', 250.00, 20, 1);


INSERT INTO Payment (Payment_ID, Customer_ID, Cart_ID, Status) VALUES
('PAY001', 'CUST001', 'CART001', 'Completed'),
('PAY002', 'CUST002', 'CART002', 'Completed'),
('PAY003', 'CUST003', 'CART003', 'Pending'),
('PAY004', 'CUST004', 'CART004', 'Completed'),
('PAY005', 'CUST005', 'CART005', 'Pending'),
('PAY006', 'CUST006', 'CART006', 'Completed'),
('PAY007', 'CUST007', 'CART007', 'Completed'),
('PAY008', 'CUST008', 'CART008', 'Completed'),
('PAY009', 'CUST009', 'CART009', 'Completed'),
('PAY010', 'CUST010', 'CART010', 'Pending'),
('PAY011', 'CUST011', 'CART011', 'Pending'),
('PAY012', 'CUST012', 'CART012', 'Pending');


INSERT INTO Orders (Order_ID, Customer_ID, Payment_ID) VALUES
('ORD001', 'CUST001', 'PAY001'),
('ORD002', 'CUST002', 'PAY002'),
('ORD003', 'CUST003', 'PAY003'),
('ORD004', 'CUST004', 'PAY004'),
('ORD005', 'CUST005', 'PAY005'),
('ORD006', 'CUST006', 'PAY006'),
('ORD007', 'CUST007', 'PAY007'),
('ORD008', 'CUST008', 'PAY008'),
('ORD009', 'CUST009', 'PAY009'),
('ORD010', 'CUST010', 'PAY010'),
('ORD011', 'CUST011', 'PAY011'),
('ORD012', 'CUST012', 'PAY012');