const db = require('../config/sqlConfig');

// GET ALL HARGA SAMPAH
exports.getAll = (req, res) => {
    const sql = 'SELECT * FROM harga_sampah ORDER BY id DESC';
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
};

// CREATE HARGA SAMPAH
exports.create = (req, res) => {
    const { kategori, nama_sampah, harga_per_kg } = req.body;

    if (!kategori || !nama_sampah || !harga_per_kg) {
        return res.status(400).json({ success: false, message: 'Data tidak lengkap' });
    }

    const sql = 'INSERT INTO harga_sampah (kategori, nama_sampah, harga_per_kg) VALUES (?, ?, ?)';
    db.query(sql, [kategori, nama_sampah, harga_per_kg], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json({ success: true, message: 'Harga berhasil ditambahkan', id: result.insertId });
    });
};

// UPDATE HARGA SAMPAH
exports.update = (req, res) => {
    const { id } = req.params;
    const { kategori, nama_sampah, harga_per_kg } = req.body;

    const sql = 'UPDATE harga_sampah SET kategori=?, nama_sampah=?, harga_per_kg=? WHERE id=?';
    db.query(sql, [kategori, nama_sampah, harga_per_kg, id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });

        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: 'Data tidak ditemukan' });
        }

        res.json({ success: true, message: 'Harga berhasil diupdate' });
    });
};

// DELETE HARGA SAMPAH
exports.remove = (req, res) => {
    const { id } = req.params;
    const sql = 'DELETE FROM harga_sampah WHERE id=?';
    db.query(sql, [id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });

        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: 'Data tidak ditemukan' });
        }

        res.json({ success: true, message: 'Harga berhasil dihapus' });
    });
};