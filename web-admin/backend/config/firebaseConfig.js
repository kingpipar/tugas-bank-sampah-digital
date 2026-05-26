const admin = require('firebase-admin');
const path = require('path');

// Inisialisasi Firebase Admin SDK
// File serviceAccountKey.json harus di-download dari Firebase Console
// → Project Settings → Service Accounts → Generate new private key
const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');

let db;

try {
    const serviceAccount = require(serviceAccountPath);

    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });

    db = admin.firestore();
    console.log('✅ Firebase Firestore Connected');

} catch (error) {
    console.warn('⚠️ Firebase belum dikonfigurasi. Letakkan serviceAccountKey.json di folder config/');
    console.warn('   Download dari: Firebase Console → Project Settings → Service Accounts');

    // Buat dummy db agar server tetap jalan tanpa Firebase
    db = null;
}

module.exports = { admin, db };
