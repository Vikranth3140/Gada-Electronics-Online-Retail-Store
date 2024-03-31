create database gada_electronics;


USE gada_electronics;

DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Address;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Warehouse;
DROP TABLE IF EXISTS Warehouse_Manager;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Cart;
DROP TABLE IF EXISTS Orders;


CREATE TABLE Customer (
    Customer_ID VARCHAR(20) NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    PhoneNo VARCHAR(10) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Current_Address_ID VARCHAR(20),
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

CREATE TABLE Categories (
	Category VARCHAR(100) UNIQUE NOT NULL,
    CategoryURL VARCHAR(2000) NOT NULL
);

CREATE TABLE Product (
    Product_ID VARCHAR(20) NOT NULL,
    Manufacturer VARCHAR(255) NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Category VARCHAR(100) NOT NULL,
    ImgURL VARCHAR(2000) NOT NULL,
    Description VARCHAR(1000) NOT NULL,
    -- Quantity INT NOT NULL CHECK (Quantity >= 0),
    Discount DECIMAL(5, 2) NOT NULL CHECK (Discount >= 0 AND Discount <= 100),
    PRIMARY KEY (Product_ID),
    FOREIGN KEY (Category) REFERENCES Categories(Category)
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
    Pincode VARCHAR(20) NOT NULL  UNIQUE,
    Username VARCHAR(255) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    PRIMARY KEY (Manager_ID),
    FOREIGN KEY (Pincode) REFERENCES Warehouse(Pincode)
);

CREATE TABLE Payment (
    Payment_ID VARCHAR(20) NOT NULL,
    Customer_ID VARCHAR(20) NOT NULL,
    Cart_ID VARCHAR(20) NOT NULL UNIQUE,
    
    Status VARCHAR(255) NOT NULL,
    PRIMARY KEY (Payment_ID, Cart_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
);

CREATE TABLE Cart (
    Cart_ID VARCHAR(20) NOT NULL,
    Customer_ID VARCHAR(20) NOT NULL,
    Product_ID VARCHAR(20) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Offer DECIMAL(10, 2) NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Warehouse_ID VARCHAR(20),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID),
    FOREIGN KEY (Cart_ID) REFERENCES Payment(Cart_ID),
    FOREIGN KEY (Warehouse_ID) REFERENCES Warehouse(Pincode)
);

CREATE TABLE Orders (
    Order_ID VARCHAR(20) NOT NULL,
    Customer_ID VARCHAR(20) NOT NULL,
    Payment_ID VARCHAR(20) NOT NULL,
    PRIMARY KEY (Order_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    FOREIGN KEY (Payment_ID) REFERENCES Payment(Payment_ID)
);


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

INSERT INTO Categories (Category, CategoryURL) VALUES
('Laptops', 'https://source.unsplash.com/featured/?laptop'),
('Smartphones', 'https://source.unsplash.com/featured/?smartphone'),
('Headphones', 'https://source.unsplash.com/featured/?headphones'),
('Tablets', 'https://source.unsplash.com/featured/?tablet'),
('Smartwatches', 'https://source.unsplash.com/featured/?smartwatch');

INSERT INTO Product (Product_ID, Manufacturer, Name, Price, Category, ImgURL, Description, Quantity, Discount) VALUES
('LAP001', 'Lenovo', 'IdeaPad 3', 459.99, 'Laptops', 'URL_PLACEHOLDER', '15.6" Laptop - AMD Ryzen 5 - 8GB Memory - 256GB SSD', 10, 5.00),
('LAP002', 'HP', 'Pavilion 15', 629.99, 'Laptops', 'URL_PLACEHOLDER', '15.6" Laptop - Intel Core i5 - 8GB Memory - 512GB SSD', 12, 7.00),
('LAP003', 'Dell', 'Inspiron 15', 549.99, 'Laptops', 'URL_PLACEHOLDER', '15.6" Laptop - Intel Core i3 - 8GB Memory - 1TB HDD', 8, 10.00),
('LAP004', 'Acer', 'Aspire 5', 479.99, 'Laptops', 'URL_PLACEHOLDER', '15.6" Laptop - AMD Ryzen 3 - 8GB Memory - 256GB SSD', 15, 0.00),
('LAP005', 'ASUS', 'VivoBook 15', 499.99, 'Laptops', 'URL_PLACEHOLDER', '15.6" Laptop - Intel Core i3 - 8GB Memory - 256GB SSD', 9, 5.00),
('LAP006', 'Apple', 'MacBook Air', 999.99, 'Laptops', 'URL_PLACEHOLDER', '13.3" Laptop - Apple M1 chip - 8GB Memory - 256GB SSD', 20, 0.00),
('LAP007', 'Microsoft', 'Surface Laptop 4', 999.99, 'Laptops', 'URL_PLACEHOLDER', '13.5" Touch-Screen - Intel Core i5 - 8GB Memory - 512GB SSD', 7, 10.00),
('LAP008', 'Lenovo', 'ThinkPad X1 Carbon', 1429.99, 'Laptops', 'URL_PLACEHOLDER', '14" Laptop - Intel Core i7 - 16GB Memory - 1TB SSD', 5, 15.00),
('LAP009', 'HP', 'Spectre x360', 1599.99, 'Laptops', 'URL_PLACEHOLDER', '13.3" 2-in-1 Laptop - Intel Core i7 - 16GB Memory - 512GB SSD', 4, 5.00),
('LAP010', 'Dell', 'XPS 15', 1849.99, 'Laptops', 'URL_PLACEHOLDER', '15.6" Laptop - Intel Core i7 - 16GB Memory - 1TB SSD', 6, 10.00),
('LAP011', 'Acer', 'Nitro 5', 829.99, 'Laptops', 'URL_PLACEHOLDER', '15.6" Gaming Laptop - AMD Ryzen 5 - 16GB Memory - 256GB SSD', 8, 0.00),
('LAP012', 'ASUS', 'ROG Zephyrus G14', 1449.99, 'Laptops', 'URL_PLACEHOLDER', '14" Gaming Laptop - AMD Ryzen 9 - 16GB Memory - 1TB SSD', 3, 5.00),
('LAP013', 'Apple', 'MacBook Pro', 1299.99, 'Laptops', 'URL_PLACEHOLDER', '13" Laptop - Apple M1 chip - 8GB Memory - 256GB SSD', 11, 0.00),
('LAP014', 'Microsoft', 'Surface Pro 7', 899.99, 'Laptops', 'URL_PLACEHOLDER', '12.3" Touch-Screen - Intel Core i5 - 8GB Memory - 128GB SSD', 10, 10.00),
('LAP015', 'Lenovo', 'Yoga 7i', 949.99, 'Laptops', 'URL_PLACEHOLDER', '14" 2-in-1 Laptop - Intel Core i5 - 12GB Memory - 512GB SSD', 7, 5.00),
('LAP016', 'HP', 'Elite Dragonfly', 2199.99, 'Laptops', 'URL_PLACEHOLDER', '13.3" 2-in-1 Laptop - Intel Core i7 - 16GB Memory - 1TB SSD', 3, 10.00),
('LAP017', 'Dell', 'Alienware m15', 1999.99, 'Laptops', 'URL_PLACEHOLDER', '15.6" Gaming Laptop - Intel Core i7 - 16GB Memory - 512GB SSD', 5, 5.00),
('LAP018', 'Acer', 'Swift 3', 679.99, 'Laptops', 'URL_PLACEHOLDER', '14" Laptop - AMD Ryzen 7 - 8GB Memory - 512GB SSD', 9, 0.00),
('LAP019', 'ASUS', 'ZenBook 13', 849.99, 'Laptops', 'URL_PLACEHOLDER', '13.3" Laptop - Intel Core i5 - 8GB Memory - 512GB SSD', 12, 5.00),
('LAP020', 'Apple', 'MacBook Pro 16"', 2399.99, 'Laptops', 'URL_PLACEHOLDER', '16" Laptop - Intel Core i9 - 16GB Memory - 1TB SSD', 2, 5.00);

INSERT INTO Product (Product_ID, Manufacturer, Name, Price, Category, ImgURL, Description, Quantity, Discount) VALUES
('SMP001', 'Samsung', 'Galaxy S21', 799.99, 'Smartphones', 'URL_PLACEHOLDER', '128GB - Phantom Gray', 15, 10.00),
('SMP002', 'Apple', 'iPhone 12', 699.99, 'Smartphones', 'URL_PLACEHOLDER', '64GB - Black', 20, 5.00),
('SMP003', 'OnePlus', 'OnePlus 9', 729.99, 'Smartphones', 'URL_PLACEHOLDER', '128GB - Winter Mist', 18, 0.00),
('SMP004', 'Google', 'Pixel 5', 599.99, 'Smartphones', 'URL_PLACEHOLDER', '128GB - Just Black', 10, 7.50),
('SMP005', 'Xiaomi', 'Mi 11', 749.99, 'Smartphones', 'URL_PLACEHOLDER', '256GB - Horizon Blue', 12, 0.00),
('SMP006', 'Samsung', 'Galaxy Note 20', 999.99, 'Smartphones', 'URL_PLACEHOLDER', '256GB - Mystic Bronze', 8, 15.00),
('SMP007', 'Apple', 'iPhone SE', 399.99, 'Smartphones', 'URL_PLACEHOLDER', '64GB - (PRODUCT)RED', 25, 5.00),
('SMP008', 'OnePlus', 'Nord N10', 299.99, 'Smartphones', 'URL_PLACEHOLDER', '128GB - Midnight Ice', 30, 10.00),
('SMP009', 'Google', 'Pixel 4a', 349.99, 'Smartphones', 'URL_PLACEHOLDER', '128GB - Just Black', 20, 0.00),
('SMP010', 'Xiaomi', 'Redmi Note 10', 199.99, 'Smartphones', 'URL_PLACEHOLDER', '64GB - Lake Green', 25, 5.00),
('SMP011', 'Samsung', 'Galaxy A52', 499.99, 'Smartphones', 'URL_PLACEHOLDER', '128GB - Awesome Black', 15, 10.00),
('SMP012', 'Apple', 'iPhone 11', 599.99, 'Smartphones', 'URL_PLACEHOLDER', '128GB - Purple', 10, 5.00),
('SMP013', 'OnePlus', '8T', 749.99, 'Smartphones', 'URL_PLACEHOLDER', '256GB - Aquamarine Green', 12, 0.00),
('SMP014', 'Google', 'Pixel 4', 799.99, 'Smartphones', 'URL_PLACEHOLDER', '64GB - Clearly White', 7, 10.00),
('SMP015', 'Xiaomi', 'Mi 10T Pro', 599.99, 'Smartphones', 'URL_PLACEHOLDER', '128GB - Cosmic Black', 9, 5.00),
('SMP016', 'Samsung', 'Galaxy S20 FE', 699.99, 'Smartphones', 'URL_PLACEHOLDER', '128GB - Cloud Navy', 14, 7.50),
('SMP017', 'Apple', 'iPhone 12 Mini', 729.99, 'Smartphones', 'URL_PLACEHOLDER', '64GB - Blue', 20, 5.00),
('SMP018', 'OnePlus', '7 Pro', 669.99, 'Smartphones', 'URL_PLACEHOLDER', '256GB - Nebula Blue', 11, 10.00),
('SMP019', 'Google', 'Pixel 3', 499.99, 'Smartphones', 'URL_PLACEHOLDER', '64GB - Not Pink', 16, 15.00),
('SMP020', 'Xiaomi', 'Poco X3 NFC', 229.99, 'Smartphones', 'URL_PLACEHOLDER', '64GB - Shadow Gray', 22, 5.00);

INSERT INTO Product (Product_ID, Manufacturer, Name, Price, Category, ImgURL, Description, Quantity, Discount) VALUES
('HPN001', 'Sony', 'WH-1000XM4', 349.99, 'Headphones', 'URL_PLACEHOLDER', 'Wireless Noise Cancelling Over-the-Ear Headphones', 20, 10.00),
('HPN002', 'Bose', 'QuietComfort 35 II', 299.99, 'Headphones', 'URL_PLACEHOLDER', 'Wireless Noise Cancelling Headphones', 15, 5.00),
('HPN003', 'Sennheiser', 'HD 450BT', 149.99, 'Headphones', 'URL_PLACEHOLDER', 'Wireless Noise Cancelling Headphones', 25, 0.00),
('HPN004', 'JBL', 'Tune 750BTNC', 129.99, 'Headphones', 'URL_PLACEHOLDER', 'Over-Ear Wireless Noise Cancelling Headphones', 30, 7.50),
('HPN005', 'Beats', 'Solo Pro', 299.99, 'Headphones', 'URL_PLACEHOLDER', 'Wireless Noise Cancelling On-Ear Headphones', 18, 5.00),
('HPN006', 'Sony', 'WF-1000XM3', 229.99, 'Headphones', 'URL_PLACEHOLDER', 'True Wireless Noise Cancelling In-Ear Headphones', 22, 10.00),
('HPN007', 'Bose', 'SoundSport Free', 199.99, 'Headphones', 'URL_PLACEHOLDER', 'True Wireless Earbuds', 20, 0.00),
('HPN008', 'Sennheiser', 'Momentum True Wireless 2', 299.99, 'Headphones', 'URL_PLACEHOLDER', 'Noise Cancelling Earbuds', 10, 5.00),
('HPN009', 'JBL', 'Reflect Flow', 149.99, 'Headphones', 'URL_PLACEHOLDER', 'True Wireless Sport Headphones', 15, 10.00),
('HPN010', 'Beats', 'Powerbeats Pro', 249.99, 'Headphones', 'URL_PLACEHOLDER', 'Wireless Earphones', 25, 5.00),
('HPN011', 'Sony', 'WH-XB900N', 248.00, 'Headphones', 'URL_PLACEHOLDER', 'Wireless Noise Cancelling Extra Bass Headphones', 12, 7.50),
('HPN012', 'Bose', '700', 379.99, 'Headphones', 'URL_PLACEHOLDER', 'Wireless Noise Cancelling Over-the-Ear Headphones', 9, 10.00),
('HPN013', 'Sennheiser', 'PXC 550-II', 349.99, 'Headphones', 'URL_PLACEHOLDER', 'Wireless Noise Cancelling Headphones', 7, 15.00),
('HPN014', 'JBL', 'Live 650BTNC', 199.99, 'Headphones', 'URL_PLACEHOLDER', 'Wireless Over-Ear Noise Cancelling Headphones', 20, 5.00),
('HPN015', 'Beats', 'Studio3', 349.99, 'Headphones', 'URL_PLACEHOLDER', 'Wireless Noise Cancelling Over-Ear Headphones', 14, 0.00),
('HPN016', 'Sony', 'Ear Duo', 279.99, 'Headphones', 'URL_PLACEHOLDER', 'True Wireless Earbuds', 18, 10.00),
('HPN017', 'Bose', 'Sport Earbuds', 179.99, 'Headphones', 'URL_PLACEHOLDER', 'True Wireless Earbuds', 22, 5.00),
('HPN018', 'Sennheiser', 'CX 400BT', 199.99, 'Headphones', 'URL_PLACEHOLDER', 'True Wireless Earbuds', 25, 0.00),
('HPN019', 'JBL', 'Endurance Peak II', 99.99, 'Headphones', 'URL_PLACEHOLDER', 'Waterproof True Wireless Sport Earbuds', 30, 10.00),
('HPN020', 'Beats', 'Flex', 69.99, 'Headphones', 'URL_PLACEHOLDER', 'Wireless Earphones', 35, 5.00);

INSERT INTO Product (Product_ID, Manufacturer, Name, Price, Category, ImgURL, Description, Quantity, Discount) VALUES
('TBL001', 'Apple', 'iPad Pro 12.9-inch', 1099.99, 'Tablets', 'URL_PLACEHOLDER', '128GB - Space Gray', 15, 5.00),
('TBL002', 'Samsung', 'Galaxy Tab S7', 649.99, 'Tablets', 'URL_PLACEHOLDER', '128GB - Mystic Black', 20, 7.00),
('TBL003', 'Microsoft', 'Surface Pro 7', 899.99, 'Tablets', 'URL_PLACEHOLDER', '128GB - Platinum', 10, 10.00),
('TBL004', 'Lenovo', 'Tab P11 Pro', 499.99, 'Tablets', 'URL_PLACEHOLDER', '128GB - Slate Grey', 25, 0.00),
('TBL005', 'Amazon', 'Fire HD 10', 149.99, 'Tablets', 'URL_PLACEHOLDER', '32GB - Black', 30, 15.00),
('TBL006', 'Apple', 'iPad Air', 599.99, 'Tablets', 'URL_PLACEHOLDER', '64GB - Sky Blue', 18, 5.00),
('TBL007', 'Samsung', 'Galaxy Tab A7', 229.99, 'Tablets', 'URL_PLACEHOLDER', '32GB - Gold', 25, 10.00),
('TBL008', 'Microsoft', 'Surface Go 2', 399.99, 'Tablets', 'URL_PLACEHOLDER', '64GB - Silver', 20, 0.00),
('TBL009', 'Lenovo', 'Yoga Smart Tab', 249.99, 'Tablets', 'URL_PLACEHOLDER', '64GB - Iron Grey', 15, 5.00),
('TBL010', 'Amazon', 'Fire HD 8', 89.99, 'Tablets', 'URL_PLACEHOLDER', '32GB - White', 40, 10.00),
('TBL011', 'Apple', 'iPad Mini', 399.99, 'Tablets', 'URL_PLACEHOLDER', '64GB - Space Gray', 22, 0.00),
('TBL012', 'Samsung', 'Galaxy Tab S6 Lite', 349.99, 'Tablets', 'URL_PLACEHOLDER', '64GB - Chiffon Pink', 18, 7.50),
('TBL013', 'Microsoft', 'Surface Pro X', 999.99, 'Tablets', 'URL_PLACEHOLDER', '128GB - Matte Black', 10, 5.00),
('TBL014', 'Lenovo', 'Tab M10 Plus', 179.99, 'Tablets', 'URL_PLACEHOLDER', '32GB - Platinum Grey', 30, 10.00),
('TBL015', 'Amazon', 'Fire 7', 49.99, 'Tablets', 'URL_PLACEHOLDER', '16GB - Plum', 50, 15.00),
('TBL016', 'Apple', 'iPad 10.2-inch', 329.99, 'Tablets', 'URL_PLACEHOLDER', '32GB - Silver', 25, 5.00),
('TBL017', 'Samsung', 'Galaxy Tab Active3', 489.99, 'Tablets', 'URL_PLACEHOLDER', '64GB - Black', 20, 10.00),
('TBL018', 'Microsoft', 'Surface Book 3', 1599.99, 'Tablets', 'URL_PLACEHOLDER', '256GB - Platinum', 5, 0.00),
('TBL019', 'Lenovo', 'Duet Chromebook', 299.99, 'Tablets', 'URL_PLACEHOLDER', '128GB - Ice Blue + Iron Grey', 15, 10.00),
('TBL020', 'Amazon', 'Fire HD 8 Kids Edition', 139.99, 'Tablets', 'URL_PLACEHOLDER', '32GB - Blue Kid-Proof Case', 35, 5.00);

INSERT INTO Warehouse (Pincode, Product_ID, Warehouse_Quantity) VALUES
('62704', 'LAP001', 8),
('62704', 'LAP004', 10),
('62704', 'LAP007', 5),
('62704', 'LAP010', 3),
('62704', 'LAP013', 7),
('62704', 'LAP016', 2),
('62704', 'LAP019', 6),
('62704', 'SMP003', 12),
('62704', 'SMP006', 4),
('62704', 'SMP009', 8),
('62704', 'SMP012', 6),
('62704', 'SMP015', 5),
('62704', 'SMP018', 9),
('62704', 'HPN009', 6),
('62704', 'HPN012', 3),
('62704', 'HPN015', 7),
('62704', 'HPN018', 10),
('62704', 'TBL007', 15),
('62704', 'TBL010', 20),
('62704', 'TBL013', 4),
('62704', 'TBL016', 12),
('62704', 'TBL019', 8),
('06830', 'LAP006', 5),
('06830', 'LAP009', 2),
('06830', 'LAP012', 3),
('06830', 'LAP015', 4),
('06830', 'LAP018', 6),
('06830', 'SMP001', 8),
('06830', 'SMP004', 6),
('06830', 'SMP007', 10),
('06830', 'SMP010', 10),
('06830', 'SMP013', 5),
('06830', 'SMP016', 7),
('06830', 'SMP019', 9),
('06830', 'HPN002', 8),
('06830', 'HPN005', 6),
('06830', 'HPN008', 4),
('06830', 'HPN011', 7),
('06830', 'HPN014', 10),
('06830', 'HPN017', 12),
('06830', 'HPN020', 15),
('06830', 'TBL003', 5),
('06830', 'TBL006', 8),
('06830', 'TBL009', 7),
('06830', 'TBL012', 8),
('06830', 'TBL015', 20),
('06830', 'TBL018', 3),
('53703', 'LAP002', 6),
('53703', 'LAP005', 4),
('53703', 'LAP008', 3),
('53703', 'LAP011', 4),
('53703', 'LAP014', 5),
('53703', 'LAP017', 2),
('53703', 'LAP020', 1),
('53703', 'SMP002', 10),
('53703', 'SMP005', 6),
('53703', 'SMP008', 12),
('53703', 'SMP011', 8),
('53703', 'SMP014', 4),
('53703', 'SMP017', 9),
('53703', 'SMP020', 11),
('53703', 'HPN001', 7),
('53703', 'HPN003', 10),
('53703', 'HPN005', 10),
('53703', 'HPN006', 8),
('53703', 'HPN007', 9),
('53703', 'HPN009', 12),
('53703', 'HPN010', 15),
('53703', 'HPN012', 5),
('53703', 'HPN013', 4),
('53703', 'HPN015', 6),
('53703', 'HPN016', 8),
('53703', 'HPN018', 11),
('53703', 'HPN019', 14),
('53703', 'TBL001', 6),
('53703', 'TBL004', 12),
('53703', 'TBL007', 10),
('53703', 'TBL010', 15),
('53703', 'TBL013', 3),
('53703', 'TBL016', 9),
('53703', 'TBL019', 9),
('53703', 'TBL020', 17);

INSERT INTO Warehouse_Manager (Manager_ID, Pincode, Username, Password) VALUES
('WM001', '62704', 'manager1', 'wm_password1'),
('WM002', '06830', 'manager2', 'wm_password2'),
('WM003', '53703', 'manager3', 'wm_password3');

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


DELIMITER $$
CREATE TRIGGER RestockProductsAfterSale
AFTER UPDATE ON Warehouse
FOR EACH ROW
BEGIN
    IF OLD.Warehouse_Quantity > NEW.Warehouse_Quantity AND NEW.Warehouse_Quantity < 5 THEN
        -- Assuming 5 as the minimum threshold for a specific warehouse
        UPDATE Warehouse
        SET Warehouse_Quantity = 20 -- Restocking to quantity of 20 in the specific warehouse
        WHERE Product_ID = NEW.Product_ID AND Pincode = NEW.Pincode;
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER ClearCartAfterPayment
AFTER UPDATE ON Payment
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Completed' THEN
        DELETE FROM Cart WHERE Cart_ID = NEW.Cart_ID;
    END IF;
END$$
DELIMITER ;