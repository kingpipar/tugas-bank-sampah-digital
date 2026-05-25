const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
const PORT = 3000; 

app.use(cors({ origin: '*' }));
app.use(express.json());

const db = mysql.createPool({
    host: '136.116.185.104',
    user: 'admin',
    password: 'password',
    database: 'testlagi',
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

app.get('/api/stats', (req, res) => {
    const query = `
        SELECT 
            (SELECT COUNT(DISTINCT nama_warga) FROM laporan_setoran) AS total_warga,
            (SELECT SUM(berat_kg) FROM laporan_setoran) AS total_berat,
            (SELECT SUM(total_harga) FROM laporan_setoran) AS total_kas,
            (SELECT COUNT(*) FROM request_jemput) AS total_jemput,
            (SELECT COUNT(*) FROM transaksi_penukaran) AS total_sembako
    `;

    db.query(query, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        const data = results[0] || {};
        res.json({
            total_warga: data.total_warga || 0,
            total_berat: data.total_berat || 0,
            total_kas: data.total_kas || 0,
            total_jemput: data.total_jemput || 0,
            total_sembako: data.total_sembako || 0
        });
    });
});

const getHargaHandler = (req, res) => {
    const sql = 'SELECT * FROM harga_sampah ORDER BY id DESC';
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
};
app.get('/api/harga', getHargaHandler);
app.get('/api/harga_sampah', getHargaHandler);

app.get('/api/harga/stats', (req, res) => {
    const sql = `
        SELECT 
            COUNT(DISTINCT kategori) AS total_kategori,
            MAX(harga_per_kg) AS harga_tertinggi,
            AVG(harga_per_kg) AS harga_rata_rata
        FROM harga_sampah
    `;
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        const data = results[0] || {};
        res.json({
            total_kategori: data.total_kategori || 0,
            harga_tertinggi: data.harga_tertinggi || 0,
            harga_rata_rata: Math.round(data.harga_rata_rata || 0)
        });
    });
});

app.post('/api/harga', (req, res) => {
    const { kategori, nama_sampah, harga_per_kg } = req.body;
    const sql = 'INSERT INTO harga_sampah (kategori, nama_sampah, harga_per_kg) VALUES (?, ?, ?)';
    db.query(sql, [kategori, nama_sampah, harga_per_kg], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json({ success: true, message: 'Data berhasil ditambahkan' });
    });
});

app.put('/api/harga/:id', (req, res) => {
    const { id } = req.params;
    const { kategori, nama_sampah, harga_per_kg } = req.body;
    const sql = 'UPDATE harga_sampah SET kategori = ?, nama_sampah = ?, harga_per_kg = ? WHERE id = ?';
    db.query(sql, [kategori, nama_sampah, harga_per_kg, id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true, message: 'Data berhasil diperbarui' });
    });
});

app.delete('/api/harga/:id', (req, res) => {
    const { id } = req.params;
    const sql = 'DELETE FROM harga_sampah WHERE id = ?';
    db.query(sql, [id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true, message: 'Data berhasil dihapus' });
    });
});

app.get('/api/laporan', (req, res) => {
    const sql = `SELECT l.id, l.nama_warga, h.kategori, h.nama_sampah, l.berat_kg, l.total_harga, l.tanggal_setor 
                 FROM laporan_setoran l 
                 JOIN harga_sampah h ON l.id_sampah = h.id 
                 ORDER BY l.id DESC`;
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.post('/api/laporan', (req, res) => {
    const { nama_warga, id_sampah, berat_kg, total_harga } = req.body;
    const sql = 'INSERT INTO laporan_setoran (nama_warga, id_sampah, berat_kg, total_harga) VALUES (?, ?, ?, ?)';
    db.query(sql, [nama_warga, id_sampah, parseFloat(berat_kg), total_harga], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json({ success: true, message: 'Laporan berhasil ditambahkan!' });
    });
});

app.get('/api/penukaran', (req, res) => {
    const query = `
        SELECT t.id, t.nama_warga, t.jenis_penukaran, t.poin_ditukar, t.tanggal_tukar,
               v.nama_sembako
        FROM transaksi_penukaran t
        LEFT JOIN voucher_reward v ON t.id_sembako = v.id
        ORDER BY t.id DESC
    `;
    db.query(query, (err, results) => {
        if (err) {
            db.query('SELECT * FROM transaksi_penukaran ORDER BY id DESC', (err2, results2) => {
                if (err2) return res.status(500).json({ error: err2.message });
                res.json(results2);
            });
            return;
        }
        res.json(results);
    });
});

app.get('/api/request_jemput', (req, res) => {
    db.query('SELECT * FROM request_jemput ORDER BY id DESC', (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.post('/api/login', (req, res) => {
    const { email, password } = req.body;
    db.query('SELECT * FROM users WHERE email = ?', [email], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.length === 0 || results[0].password !== password) {
            return res.status(401).json({ success: false, message: 'Email atau password salah!' });
        }
        res.json({ success: true, user: results[0] });
    });
});

app.put('/api/update-profile', (req, res) => {
    const { id, nama, email } = req.body;
    const sql = 'UPDATE users SET nama = ?, email = ? WHERE id = ?';
    db.query(sql, [nama, email, id], (err, result) => {
        if (err) return res.status(500).json({ success: false, message: err.message });
        res.json({ success: true, message: 'Profil berhasil diperbarui' });
    });
});

app.put('/api/change-password', (req, res) => {
    const { id, oldPassword, newPassword } = req.body;
    db.query('SELECT password FROM users WHERE id = ?', [id], (err, results) => {
        if (err) return res.status(500).json({ success: false, message: err.message });
        if (results.length === 0 || results[0].password !== oldPassword) {
            return res.status(400).json({ success: false, message: 'Password lama salah!' });
        }
        db.query('UPDATE users SET password = ? WHERE id = ?', [newPassword, id], (err2) => {
            if (err2) return res.status(500).json({ success: false, message: err2.message });
            res.json({ success: true, message: 'Password berhasil diganti!' });
        });
    });
});

const getSembakoHandler = (req, res) => {
    db.query('SELECT * FROM voucher_reward ORDER BY id DESC', (err, results) => {
        if (err) return res.status(500).json({ error: err.message });

        const mappedResults = results.map(item => ({
            id: item.id,
            nama_sembako: item.nama_sembako || item.nama_reward || item.nama_voucher,
            harga_poin: item.harga_poin || item.poin_dibutuhkan,
            stok: item.stok
        }));
        res.json(mappedResults);
    });
};
app.get('/api/sembako', getSembakoHandler);
app.get('/api/voucher', getSembakoHandler);
app.get('/api/voucher_reward', getSembakoHandler); 

app.get('/api/notif', (req, res) => {
    res.json({
        success: true,
        message: 'Data notifikasi berhasil diambil',
        data: []
    });
});

app.get('/api/users', (req, res) => {
    db.query('SELECT * FROM users WHERE role="warga" ORDER BY id ASC', (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.get('/api/users/stats', (req, res) => {
    db.query(`
        SELECT 
            COUNT(*) AS total,
            SUM(jenis_kelamin = 'Laki-laki') AS laki,
            SUM(jenis_kelamin = 'Perempuan') AS perempuan
        FROM users WHERE role="warga"
    `, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results[0]);
    });
});

app.post('/api/users', (req, res) => {
    const { nama, email, password, rt, rw, jenis_kelamin } = req.body;
    db.query('INSERT INTO users (nama, email, password, rt, rw, jenis_kelamin, role) VALUES (?, ?, ?, ?, ?, ?, "warga")',
        [nama, email, password, rt, rw, jenis_kelamin], (err) => {
            if (err) return res.status(500).json({ error: err.message });
            res.status(201).json({ success: true });
        });
});

app.put('/api/users/:id', (req, res) => {
    const { nama, email, password, rt, rw, jenis_kelamin } = req.body;
    let sql = 'UPDATE users SET nama=?, email=?, rt=?, rw=?, jenis_kelamin=?';
    let params = [nama, email, rt, rw, jenis_kelamin];
    
    if (password) {
        sql += ', password=?';
        params.push(password);
    }
    
    sql += ' WHERE id=? AND role="warga"';
    params.push(req.params.id);

    db.query(sql, params, (err) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true });
    });
});

app.delete('/api/users/:id', (req, res) => {
    db.query('DELETE FROM users WHERE id=? AND role="warga"', [req.params.id], (err) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true });
    });
});

app.listen(PORT, () => {
    console.log(`🚀 Server Backend berjalan mulus di http://localhost:${PORT}`);
});