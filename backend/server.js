const express = require('express');

const mysql = require('mysql2');

const cors = require('cors');

const app = express();

app.use(cors());

app.use(express.json());



const db = mysql.createConnection({

    host: 'localhost',

    user: 'root',

    password: '',

    database: 'bank_sampah_digital'

});


db.connect((err) => {

    if (err) {

        console.error('Database Error:', err);

    } else {

        console.log('✅ Backend & MySQL Connected (bank_sampah_digital)');

    }

});

app.post('/api/auth/login', (req, res) => {

    const { email, password } = req.body;

    const sql = 'SELECT * FROM users WHERE email = ? AND password = ?';

    db.query(sql, [email, password], (err, results) => {

        if (err) return res.status(500).json({ success: false, message: 'Server Error' });

        if (results.length > 0) {

            res.json({ success: true, user: results[0] });

        } else {

            res.status(401).json({ success: false, message: 'Email atau password salah!' });

        }

    });

});

app.get('/api/harga', (req, res) => {

    const sql = 'SELECT * FROM harga_sampah ORDER BY id DESC';

    db.query(sql, (err, results) => {

        if (err) return res.status(500).json({ error: err.message });

        res.json(results);

    });

});


app.post('/api/harga', (req, res) => {

    const { kategori, nama_sampah, harga_per_kg } = req.body;

    const sql = 'INSERT INTO harga_sampah (kategori, nama_sampah, harga_per_kg) VALUES (?, ?, ?)';

    db.query(sql, [kategori, nama_sampah, harga_per_kg], (err, result) => {

        if (err) return res.status(500).json({ error: err.message });

        res.status(201).json({ message: 'Harga berhasil ditambahkan' });

    });

});


app.put('/api/harga/:id', (req, res) => {

    const { id } = req.params;

    const { kategori, nama_sampah, harga_per_kg } = req.body;

    const sql = 'UPDATE harga_sampah SET kategori=?, nama_sampah=?, harga_per_kg=? WHERE id=?';

    db.query(sql, [kategori, nama_sampah, harga_per_kg, id], (err, result) => {

        if (err) return res.status(500).json({ error: err.message });

        res.json({ message: 'Harga berhasil diupdate' });

    });

});


app.delete('/api/harga/:id', (req, res) => {

    const { id } = req.params;

    const sql = 'DELETE FROM harga_sampah WHERE id=?';

    db.query(sql, [id], (err, result) => {

        if (err) return res.status(500).json({ error: err.message });

        res.json({ message: 'Harga berhasil dihapus' });

    });

});

app.post('/api/laporan', (req, res) => {

    const { tanggal_setor, nama_warga, id_sampah, berat_kg, total_harga } = req.body;

    const sql = `INSERT INTO laporan_setoran (tanggal_setor, nama_warga, id_sampah, berat_kg, total_harga) VALUES (?, ?, ?, ?, ?)`;

    db.query(sql, [tanggal_setor, nama_warga, id_sampah, berat_kg, total_harga], (err, result) => {

        if (err) return res.status(500).json({ error: 'Gagal insert ke database' });

        res.status(201).json({ message: 'Berhasil menyimpan setoran!' });

    });

});

app.get('/api/laporan', (req, res) => {

    const sql = `
        SELECT l.*, h.nama_sampah, h.kategori 
        FROM laporan_setoran l 
        JOIN harga_sampah h ON l.id_sampah = h.id 
        ORDER BY l.id DESC
    `;

    db.query(sql, (err, results) => {

        if (err) return res.status(500).json({ error: err.message });

        res.json(results);

    });

});

app.get('/api/stats', (req, res) => {

    const q = `

        SELECT 

            (
                SELECT COUNT(DISTINCT nama_warga)
                FROM laporan_setoran
            ) AS total_warga,

            (
                SELECT COALESCE(SUM(berat_kg),0)
                FROM laporan_setoran
            ) AS total_berat,

            (
                SELECT COALESCE(SUM(total_harga),0)
                FROM laporan_setoran
            ) AS total_kas,

            (
                SELECT COUNT(*)
                FROM request_jemput
                WHERE status != 'Selesai'
            ) AS total_jemput,

            (
                SELECT COUNT(*)
                FROM katalog_sembako
            ) AS total_sembako

    `;

    db.query(q, (err, result) => {

        if (err) {

            console.log(err);

            return res.status(500).json({
                success: false,
                error: err
            });

        }

        res.json({

            total_warga:
                result[0].total_warga || 0,

            total_berat:
                result[0].total_berat || 0,

            total_kas:
                result[0].total_kas || 0,

            total_jemput:
                result[0].total_jemput || 0,
            
            total_sembako:
                result[0].total_sembako || 0

        });

    });

});


app.get('/api/request_jemput', (req, res) => {

    const q = `

        SELECT *
        FROM request_jemput
        ORDER BY id DESC

    `;

    db.query(q, (err, results) => {

        if (err) {

            console.log(err);

            return res.status(500).json({
                error: err.message
            });

        }

        res.json(results);

    });

});

app.put('/api/request-jemput/:id', (req, res) => {

    const { id } = req.params;

    const { status } = req.body;

    const q = `

        UPDATE request_jemput
        SET status = ?
        WHERE id = ?

    `;

    db.query(

        q,

        [status, id],

        (err, result) => {

            if (err) {

                console.log(err);

                return res.status(500).json({
                    success: false,
                    message: 'Gagal update status request'
                });

            }

            res.json({

                success: true,
                message: 'Status request berhasil diupdate'

            });

        }

    );

});

app.delete('/api/request-jemput/:id', (req, res) => {

    const { id } = req.params;

    const q = `

        DELETE FROM request_jemput
        WHERE id = ?

    `;

    db.query(q, [id], (err, result) => {

        if (err) {

            console.log(err);

            return res.status(500).json({
                success: false,
                message: 'Gagal menghapus request'
            });

        }

        res.json({

            success: true,
            message: 'Request berhasil dihapus'

        });

    });

});

// =========================================================
// PASTE KODINGAN BARU (KATALOG & TRANSAKSI) TEPAT DI SINI
// =========================================================

// 1. Get All Sembako
app.get('/api/sembako', (req, res) => {
    const sql = 'SELECT * FROM katalog_sembako ORDER BY id DESC';
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// 2. Tambah Sembako Baru (Create)
app.post('/api/sembako', (req, res) => {
    const { nama_sembako, harga_poin, stok } = req.body;
    const sql = 'INSERT INTO katalog_sembako (nama_sembako, harga_poin, stok) VALUES (?, ?, ?)';
    db.query(sql, [nama_sembako, harga_poin, stok], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json({ success: true, message: 'Sembako baru berhasil ditambahkan ke katalog!' });
    });
});

// 3. Update Data Sembako (Update)
app.put('/api/sembako/:id', (req, res) => {
    const { id } = req.params;
    const { nama_sembako, harga_poin, stok } = req.body;
    const sql = 'UPDATE katalog_sembako SET nama_sembako = ?, harga_poin = ?, stok = ? WHERE id = ?';
    db.query(sql, [nama_sembako, harga_poin, stok, id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true, message: 'Data sembako berhasil diperbarui!' });
    });
});

// 4. Hapus Sembako (Delete)
app.delete('/api/sembako/:id', (req, res) => {
    const { id } = req.params;
    const sql = 'DELETE FROM katalog_sembako WHERE id = ?';
    db.query(sql, [id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true, message: 'Sembako berhasil dihapus dari katalog!' });
    });
});

// 5. Get All Riwayat Penukaran Poin
app.get('/api/penukaran', (req, res) => {
    const sql = `
        SELECT t.id, t.nama_warga, t.jenis_penukaran, k.nama_sembako, t.poin_ditukar, t.tanggal_tukar 
        FROM transaksi_penukaran t
        LEFT JOIN katalog_sembako k ON t.id_sembako = k.id
        ORDER BY t.tanggal_tukar DESC
    `;
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// 6. Catat Transaksi Penukaran Poin Baru (Uang/Sembako)
app.post('/api/penukaran', (req, res) => {
    const { nama_warga, jenis_penukaran, id_sembako, poin_ditukar } = req.body;
    const sql = 'INSERT INTO transaksi_penukaran (nama_warga, jenis_penukaran, id_sembako, poin_ditukar) VALUES (?, ?, ?, ?)';

    db.query(sql, [nama_warga, jenis_penukaran, id_sembako || null, poin_ditukar], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });

        if (jenis_penukaran === 'Sembako' && id_sembako) {
            const updateStokSql = 'UPDATE katalog_sembako SET stok = stok - 1 WHERE id = ?';
            db.query(updateStokSql, [id_sembako], (updateErr) => {
                if (updateErr) console.error('Gagal memotong stok sembako:', updateErr.message);
            });
        }

        res.status(201).json({ success: true, message: 'Transaksi penukaran poin berhasil dicatat!' });
    });
});

// =========================================================
// BATAS AKHIR PASTE
// =========================================================

app.listen(3000, () => {

    console.log(`🚀 Server Backend berjalan di http://localhost:3000`);

});