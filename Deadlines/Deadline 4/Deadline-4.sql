use gada_electronics;

-- Retrieve all products with their respective quantities available in a specific warehouse by Pincode.
SELECT p.Product_ID, p.Name, p.Price, w.Warehouse_Quantity
FROM Product p
JOIN Warehouse w ON p.Product_ID = w.Product_ID
WHERE w.Pincode = '62704';


-- Update the quantity of a product in a customer's cart.
UPDATE Cart
SET Quantity = 2
WHERE Cart_ID = 'CART001' AND Product_ID = 'PROD001';


-- List customers who have made a purchase, along with their email and the total amount spent (consider discounts in calculations).
SELECT c.Customer_ID, c.Email, SUM((crt.Price * (1 - crt.Offer / 100)) * crt.Quantity) AS Total_Spent
FROM Customer c
JOIN Cart crt ON c.Customer_ID = crt.Customer_ID
JOIN Payment p ON crt.Cart_ID = p.Cart_ID
WHERE p.Status = 'Completed'
GROUP BY c.Customer_ID;


-- Find all products that have never been added to a cart (i.e., identify unsold products).
SELECT p.Product_ID, p.Name
FROM Product p
WHERE p.Product_ID NOT IN (SELECT DISTINCT Product_ID FROM Cart);


-- Show the total number of orders completed for each customer.
SELECT c.Customer_ID, c.Name, COUNT(o.Order_ID) AS Orders_Completed
FROM Customer c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
JOIN Payment p ON o.Payment_ID = p.Payment_ID
WHERE p.Status = 'Completed'
GROUP BY c.Customer_ID;


-- Increment the discount on all products by 5% up to a maximum of 20% discount.
UPDATE Product
SET Discount = LEAST(Discount + 5, 20);


-- List all customers and the number of addresses they have registered, including those with no registered address.
SELECT c.Customer_ID, c.Name, COUNT(a.Address_ID) AS Address_Count
FROM Customer c
LEFT JOIN Address a ON c.Customer_ID = a.Customer_ID
GROUP BY c.Customer_ID;


-- Show total sales per product, only listing those with sales exceeding 1,000 rupees.
SELECT p.Product_ID, p.Name, SUM(c.Quantity * (c.Price - (c.Price * c.Offer / 100))) AS TotalSales
FROM Product p
JOIN Cart c ON p.Product_ID = c.Product_ID
JOIN Payment pay ON c.Cart_ID = pay.Cart_ID AND pay.Status = 'Completed'
GROUP BY p.Product_ID
HAVING TotalSales > 1000;


-- Display 'Address Not Provided' if Customer doesn’t have address.
SELECT 
    c.Customer_ID,
    c.Name AS CustomerName,
    IFNULL(CONCAT(a.Street, ', ', a.City, ', ', a.State), 'Address Not Provided') AS Address
FROM 
    Customer c
LEFT JOIN Address a ON c.Customer_ID = a.Customer_ID;


-- Display top 3 most frequently purchased products.
SELECT Product_ID, Name
FROM (
  SELECT p.Product_ID, p.Name,
    RANK() OVER (PARTITION BY p.Product_ID ORDER BY COUNT(c.Cart_ID) DESC) AS PurchaseRank
  FROM Product p
  JOIN Cart c ON p.Product_ID = c.Product_ID
  JOIN Payment pay ON c.Cart_ID = pay.Cart_ID AND pay.Status = 'Completed'
  GROUP BY p.Product_ID
) AS RankedProducts
WHERE PurchaseRank <= 3;