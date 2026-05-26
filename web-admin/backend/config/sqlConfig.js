require('dotenv').config();
const mysql = require('mysql2');

const db = mysql.createConnection({
    host: process.env.DB_HOST || '35.226.121.24',
    user: process.env.DB_USER || 'admin',
    password: process.env.DB_PASS || 'password',
    database: process.env.DB_NAME || 'testprojek'
});

db.connect((err) => {
    if (err) {
        console.error('❌ MySQL Connection Error:', err.message);
    } else {
        console.log('✅ MySQL Connected (bank_sampah_digital)');
    }
});

module.exports = db;