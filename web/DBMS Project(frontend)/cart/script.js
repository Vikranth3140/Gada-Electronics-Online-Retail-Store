document.addEventListener("DOMContentLoaded", function () {
    const cartContainer = document.querySelector(".cart-container");
    const totalPriceSpan = document.getElementById("total-price");

    let cartItems = [
        { name: "Product 1", price: 10.99, quantity: 2 },
        { name: "Product 2", price: 20.49, quantity: 1 },
        { name: "Product 3", price: 15.00, quantity: 3 }
    ]; // Sample cart items

    // Function to render cart items
    function renderCart() {
        cartContainer.innerHTML = ""; // Clear previous content
        let totalPrice = 0;
        cartItems.forEach(item => {
            const cartItem = document.createElement("div");
            cartItem.classList.add("cart-item");
            cartItem.innerHTML = `
                <p>${item.name}</p>
                <div>
                    <label>Quantity:</label>
                    <input type="number" value="${item.quantity}" min="1" class="quantity-input">
                    <span class="item-price">$${(item.price * item.quantity).toFixed(2)}</span>
                </div>
            `;
            cartContainer.appendChild(cartItem);
            totalPrice += item.price * item.quantity;
        });
        totalPriceSpan.textContent = "$" + totalPrice.toFixed(2);
    }

    // Event listener for quantity change
    cartContainer.addEventListener("change", function (event) {
        if (event.target.classList.contains("quantity-input")) {
            const index = Array.from(event.target.parentElement.parentElement.parentElement.children).indexOf(event.target.parentElement.parentElement);
            const newQuantity = parseInt(event.target.value);
            cartItems[index].quantity = newQuantity;
            renderCart();
        }
    });

    // Initial rendering
    renderCart();
});
