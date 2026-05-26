function showMessage(message, color = 'green') {

    const alertBox =
        document.getElementById('alert');

    if (!alertBox) return;

    alertBox.innerHTML = message;

    alertBox.className =
        `text-${color}-500 text-sm`;

}

// Loading
function showLoading(button) {

    button.disabled = true;

    button.innerHTML =
        'Loading...';

}

// Reset loading
function hideLoading(button, text) {

    button.disabled = false;

    button.innerHTML = text;

}