document.addEventListener("DOMContentLoaded", function () {
    const addressContainer = document.querySelector(".address-container");
    const addAddressForm = document.getElementById("add-address-form");
    const selectAddressBtn = document.getElementById("select-address-btn");

    // Sample data (you can replace it with data from your database)
    let addresses = [
        "123 Main St, Cityville, ABC123",
        "456 Elm St, Townsville, XYZ456",
        "789 Oak St, Villageton, DEF789"
    ];

    // Function to render existing addresses with selection option
    function renderAddresses() {
        addressContainer.innerHTML = ""; // Clear previous content
        addresses.forEach((address, index) => {
            const addressItem = document.createElement("div");
            addressItem.classList.add("address-item");
            addressItem.innerHTML = `
                <input type="radio" id="address-${index}" name="selected-address" value="${address}">
                <label for="address-${index}">${address}</label>
            `;
            addressContainer.appendChild(addressItem);
        });
    }

    // Event listener for selecting address
    selectAddressBtn.addEventListener("click", function () {
        const selectedAddress = document.querySelector('input[name="selected-address"]:checked');
        if (selectedAddress) {
            const addressValue = selectedAddress.value;
            // Do something with the selected address, like passing it to the next page or updating the shipping information
            console.log("Selected Address:", addressValue);
            // Redirect to the next page or perform further actions
        } else {
            alert("Please select an address.");
        }
    });

    // Event listener for adding new address
    addAddressForm.addEventListener("submit", function (event) {
        event.preventDefault(); // Prevent form submission
        const newAddress = document.getElementById("new-address").value;
        addresses.push(newAddress);
        renderAddresses();
        addAddressForm.reset(); // Clear form fields after adding address
    });

    // Initial rendering
    renderAddresses();
});
