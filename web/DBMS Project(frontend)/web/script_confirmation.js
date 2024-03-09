document.addEventListener("DOMContentLoaded", function() {
    // Sample order details
    var itemCount = 5; // Change this value to reflect the actual number of items
    var deliveryDate = "March 15, 2024"; // Change this value to reflect the actual delivery date
    var totalBill = 200; // Change this value to reflect the actual total bill

    // Display order details on the page
    document.getElementById("item-count").textContent = itemCount;
    document.getElementById("delivery-date").textContent = deliveryDate;
    document.getElementById("total-bill").textContent = totalBill.toFixed(2); // Display total bill with 2 decimal places
});
