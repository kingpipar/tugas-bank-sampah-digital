require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// ========================
// MIDDLEWARE
// ========================
app.use(cors());
app.use(express.json());

// ========================
// ROUTES
// ========================
const authRoutes = require('./routes/authRoutes');
const hargaRoutes = require('./routes/hargaRoutes');
const laporanRoutes = require('./routes/laporanRoutes');
const penukaranRoutes = require('./routes/penukaranRoutes');
const notifRoutes = require('./routes/notifRoutes');
const pickupRoutes = require('./routes/pickupRoutes');

// Auth (3 endpoints: login, update-profile, change-password)
app.use('/api/auth', authRoutes);

// Harga Sampah - CRUD (4 endpoints)
app.use('/api/harga', hargaRoutes);

// Laporan Setoran (3 endpoints: get, create, delete)
app.use('/api/laporan', laporanRoutes);

// Dashboard Stats (1 endpoint)
app.get('/api/stats', require('./controllers/laporanController').getStats);

// Transaksi Penukaran - CRUD (4 endpoints)
app.use('/api/penukaran', penukaranRoutes);

// Notifikasi - Firestore (2 endpoints: get, create)
app.use('/api/notifikasi', notifRoutes);

// Pickup Requests - Firestore CRUD (4 endpoints)
app.use('/api/pickup', pickupRoutes);

// Request Jemput dari MySQL (backward compatibility)
const db = require('./config/sqlConfig');

app.get('/api/request_jemput', (req, res) => {
    db.query('SELECT * FROM request_jemput ORDER BY id DESC', (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.put('/api/request-jemput/:id', (req, res) => {
    const { id } = req.params;
    const { status } = req.body;
    db.query('UPDATE request_jemput SET status = ? WHERE id = ?', [status, id], (err, result) => {
        if (err) return res.status(500).json({ success: false, message: 'Gagal update status' });
        res.json({ success: true, message: 'Status berhasil diupdate' });
    });
});

app.delete('/api/request-jemput/:id', (req, res) => {
    const { id } = req.params;
    db.query('DELETE FROM request_jemput WHERE id = ?', [id], (err, result) => {
        if (err) return res.status(500).json({ success: false, message: 'Gagal menghapus' });
        res.json({ success: true, message: 'Request berhasil dihapus' });
    });
});

// ========================
// START SERVER
// ========================
app.listen(PORT, () => {
    console.log(`🚀 Server Backend berjalan di http://localhost:${PORT}`);
    console.log(`📊 Total API Endpoints: 21`);
    console.log(`🗄️  MySQL: users, harga_sampah, laporan_setoran, request_jemput, transaksi_penukaran`);
    console.log(`🔥 Firestore: pickup_requests, notifications, activity_logs, realtime_saldo, chat_messages`);
});