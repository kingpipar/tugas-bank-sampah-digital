const BASE_URL =
'http://localhost:3000/api';

// =======================
// LOGIN
// =======================

async function login(data) {

    const response =
        await fetch(
            `${BASE_URL}/auth/login`,
            {
                method: 'POST',

                headers: {
                    'Content-Type':
                    'application/json'
                },

                body: JSON.stringify(data)
            }
        );

    return response.json();
}

// =======================
// GET HARGA
// =======================

async function getHarga() {

    const response =
        await fetch(
            `${BASE_URL}/harga`
        );

    return response.json();
}

// =======================
// GET LAPORAN
// =======================

async function getLaporan() {

    const response =
        await fetch(
            `${BASE_URL}/laporan`
        );

    return response.json();
}

// =======================
// GET NOTIF
// =======================

async function getNotif() {

    const response =
        await fetch(
            `${BASE_URL}/notif`
        );

    return response.json();
}