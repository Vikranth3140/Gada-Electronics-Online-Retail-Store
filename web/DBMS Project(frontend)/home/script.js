document.addEventListener("DOMContentLoaded", function () {
    const productContainer = document.querySelector(".product-container");

    // Sample data (you can replace it with data from your database)
    const products = [
        { name: "Smartphone", price: "$999.99", description: "Latest model with advanced features" },
        { name: "Smart TV", price: "$1200.00", description: "High definition smart TV with voice control" },
        { name: "Bluetooth Speaker", price: "$150.00", description: "Portable high-quality sound" },
        { name: "Laptop", price: "$1500.00", description: "Lightweight, high performance for professionals" },
        { name: "Microwave Oven", price: "$250.00", description: "Fast cooking with smart settings" },
        { name: "Treadmill", price: "$800.00", description: "Compact design with multiple exercise modes" },
        { name: "Video Game Console", price: "$300.00", description: "Latest gaming console with VR capabilities" },
        { name: "Printer", price: "$200.00", description: "High-speed, efficient document printing" },
        { name: "Tablet", price: "$600.00", description: "Lightweight and powerful for on-the-go use" },
        { name: "Headphones", price: "$100.00", description: "Noise-cancelling, long battery life" },
        { name: "Air Conditioner", price: "$1000.00", description: "Energy-efficient cooling and heating" },
        { name: "Smart Watch", price: "$250.00", description: "Fitness tracking and notifications" }
    ];
    

    // Function to create product cards
    function createProductCard(product) {
        const card = document.createElement("div");
        card.classList.add("product-card");

        card.innerHTML = `
            <h3>${product.name}</h3>
            <p><strong>Price:</strong> ${product.price}</p>
            <p><strong>Description:</strong> ${product.description}</p>
        `;

        return card;
    }

    // Populate product container with product cards
    products.forEach(product => {
        const card = createProductCard(product);
        productContainer.appendChild(card);
    });
});
