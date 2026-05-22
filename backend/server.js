const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
const PORT = 3000; // Disamakan dengan port utama file html project kamu

// Middleware - Mengizinkan akses dari browser tanpa blokir CORS
app.use(cors({ origin: '*' }));
app.use(express.json());

// Koneksi Database menggunakan Pool (Lebih Stabil)
const db = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'bank_sampah_digital',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

db.getConnection((err, connection) => {
    if (err) {
        console.error('❌ Gagal konek ke database:', err.message);
    } else {
        console.log(`✅ Database terhubung (bank_sampah_digital) di Port ${PORT}`);
        connection.release();
    }
});

// ==========================================
// API ENDPOINT: HARGA SAMPAH (ALL CRUD)
// ==========================================

// 1. GET ALL DATA
const getHargaHandler = (req, res) => {
    const sql = 'SELECT * FROM harga_sampah ORDER BY id DESC';
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
};
app.get('/api/harga', getHargaHandler);
app.get('/api/harga_sampah', getHargaHandler);

// 2. POST (TAMBAH DATA)
const postHargaHandler = (req, res) => {
    const { kategori, nama_sampah, harga_per_kg } = req.body;
    if (!kategori || !nama_sampah || !harga_per_kg) {
        return res.status(400).json({ message: 'Semua kolom wajib diisi!' });
    }
    const sql = 'INSERT INTO harga_sampah (kategori, nama_sampah, harga_per_kg) VALUES (?, ?, ?)';
    db.query(sql, [kategori, nama_sampah, parseInt(harga_per_kg)], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json({ success: true, message: 'Data berhasil disimpan!', id: result.insertId });
    });
};
app.post('/api/harga', postHargaHandler);
app.post('/api/harga_sampah', postHargaHandler);

// 3. PUT (EDIT DATA)
const putHargaHandler = (req, res) => {
    const { id } = req.params;
    const { kategori, nama_sampah, harga_per_kg } = req.body;
    if (!kategori || !nama_sampah || !harga_per_kg) {
        return res.status(400).json({ message: 'Semua kolom wajib diisi!' });
    }
    const sql = 'UPDATE harga_sampah SET kategori = ?, nama_sampah = ?, harga_per_kg = ? WHERE id = ?';
    db.query(sql, [kategori, nama_sampah, parseInt(harga_per_kg), id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true, message: 'Data berhasil diperbarui!' });
    });
};
app.put('/api/harga/:id', putHargaHandler);
app.put('/api/harga_sampah/:id', putHargaHandler);

// 4. DELETE (HAPUS DATA)
const deleteHargaHandler = (req, res) => {
    const { id } = req.params;
    const sql = 'DELETE FROM harga_sampah WHERE id = ?';
    db.query(sql, [id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true, message: 'Data berhasil dihapus!' });
    });
};
app.delete('/api/harga/:id', deleteHargaHandler);
app.delete('/api/harga_sampah/:id', deleteHargaHandler);

// ==========================================
// API ENDPOINT LAIN (LOGIN, JEMPUT, LAPORAN)
// ==========================================
app.post('/api/auth/login', (req, res) => {
    const { email, password } = req.body;
    const sql = 'SELECT * FROM users WHERE email = ?';
    db.query(sql, [email], (err, results) => {
        if (err) return res.status(500).json({ success: false, error: err.message });
        if (results.length === 0 || results[0].password !== password) {
            return res.status(401).json({ success: false, message: 'Email atau password salah!' });
        }
        res.json({ success: true, user: results[0] });
    });
});

app.get('/api/request_jemput', (req, res) => {
    db.query('SELECT * FROM request_jemput ORDER BY id DESC', (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.get('/api/laporan', (req, res) => {
    const sql = `SELECT l.id, l.nama_warga, h.nama_sampah, l.berat_kg, l.total_harga, l.tanggal_setor 
                 FROM laporan_setoran l JOIN harga_sampah h ON l.id_sampah = h.id ORDER BY l.id DESC`;
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.post('/api/laporan', (req, res) => {
    const { nama_warga, id_sampah, berat_kg, total_harga } = req.body;
    const sql = 'INSERT INTO laporan_setoran (nama_warga, id_sampah, berat_kg, total_harga) VALUES (?, ?, ?, ?)';
    db.query(sql, [nama_warga, id_sampah, parseFloat(berat_kg), parseInt(total_harga)], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json({ success: true, id: result.insertId });
    });
});

app.get('/api/status', (req, res) => {
    res.json({ status: 'ok', database: 'connected' });
});

app.listen(PORT, () => {
    console.log(`🚀 Server berjalan aktif di http://localhost:${PORT}`);
});