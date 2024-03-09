document.addEventListener("DOMContentLoaded", function () {
    const paymentForm = document.getElementById("payment-form");
    const cardDetails = document.getElementById("card-details");
    const netBankingDetails = document.getElementById("net-banking-details");
    const upiDetails = document.getElementById("upi-details");

    // Function to toggle display of payment details based on selected payment method
    function togglePaymentDetails() {
        const selectedMethod = document.querySelector('input[name="payment-method"]:checked').value;
        if (selectedMethod === "card") {
            cardDetails.style.display = "block";
            netBankingDetails.style.display = "none";
            upiDetails.style.display = "none";
        } else if (selectedMethod === "net-banking") {
            cardDetails.style.display = "none";
            netBankingDetails.style.display = "block";
            upiDetails.style.display = "none";
        } else if (selectedMethod === "upi") {
            cardDetails.style.display = "none";
            netBankingDetails.style.display = "none";
            upiDetails.style.display = "block";
        }
    }

    // Event listener for radio button change
    const paymentMethodRadios = document.querySelectorAll('input[name="payment-method"]');
    paymentMethodRadios.forEach(radio => {
        radio.addEventListener("change", togglePaymentDetails);
    });

    paymentForm.addEventListener("submit", function (event) {
        event.preventDefault(); // Prevent form submission

        // Handle payment based on the selected method
        const selectedMethod = document.querySelector('input[name="payment-method"]:checked').value;
        if (selectedMethod === "card") {
            handleCardPayment();
        } else if (selectedMethod === "net-banking") {
            handleNetBankingPayment();
        } else if (selectedMethod === "upi") {
            handleUpiPayment();
        }
    });

    // Functions for handling different payment methods
    function handleCardPayment() {
        const cardNumber = document.getElementById("card-number").value;
        const expiryDate = document.getElementById("expiry-date").value;
        const cvv = document.getElementById("cvv").value;
        // Perform card payment processing
        simulatePaymentProcessing();
    }

    function handleNetBankingPayment() {
        const selectedBank = document.getElementById("bank-select").value;
        // Perform net banking payment processing
        simulatePaymentProcessing();
    }

    function handleUpiPayment() {
        const upiId = document.getElementById("upi-id").value;
        // Perform UPI payment processing
        simulatePaymentProcessing();
    }

    // Simulate payment processing (you can replace this with actual payment processing)
    function simulatePaymentProcessing() {
        setTimeout(() => {
            alert("Payment successful!");
            paymentForm.reset(); // Clear form fields after successful payment
        }, 2000);
    }

    // Initial display setup
    togglePaymentDetails();
});
