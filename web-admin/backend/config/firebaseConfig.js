const admin = require('firebase-admin');
const path = require('path');
let db;
const firebaseEnv = process.env._FIREBASE_SERVICE_ACCOUNT || process.env.FIREBASE_SERVICE_ACCOUNT;

if (firebaseEnv) {
    try {
        const serviceAccount = JSON.parse(firebaseEnv);

        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });

        db = admin.firestore();
        console.log('✅ Firebase Firestore Connected via Environment Variable (Production)');
    } catch (error) {
        console.error('❌ Gagal membaca FIREBASE_SERVICE_ACCOUNT dari Env:', error.message);
        db = null;
    }
} else {
    const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');
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
}
module.exports = { admin, db };
