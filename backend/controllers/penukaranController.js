const db = require('../config/sqlConfig');

// GET ALL TRANSAKSI PENUKARAN
exports.getAll = (req, res) => {
    const sql = 'SELECT * FROM transaksi_penukaran ORDER BY id DESC';
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
};

// CREATE TRANSAKSI PENUKARAN
exports.create = (req, res) => {
    const { nama_warga, jenis_penukaran, jumlah_poin, nilai_tukar, keterangan } = req.body;

    if (!nama_warga || !jenis_penukaran || !jumlah_poin || !nilai_tukar) {
        return res.status(400).json({ success: false, message: 'Data tidak lengkap' });
    }

    const sql = `INSERT INTO transaksi_penukaran (nama_warga, jenis_penukaran, jumlah_poin, nilai_tukar, keterangan) VALUES (?, ?, ?, ?, ?)`;
    db.query(sql, [nama_warga, jenis_penukaran, jumlah_poin, nilai_tukar, keterangan || ''], (err, result) => {
        if (err) return res.status(500).json({ success: false, error: err.sqlMessage || err.message });
        res.status(201).json({ success: true, message: 'Transaksi penukaran berhasil dicatat', id: result.insertId });
    });
};

// UPDATE STATUS TRANSAKSI PENUKARAN
exports.update = (req, res) => {
    const { id } = req.params;
    const { status } = req.body;

    if (!status) {
        return res.status(400).json({ success: false, message: 'Status wajib diisi' });
    }

    const sql = 'UPDATE transaksi_penukaran SET status = ? WHERE id = ?';
    db.query(sql, [status, id], (err, result) => {
        if (err) return res.status(500).json({ success: false, message: err.message });

        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: 'Data tidak ditemukan' });
        }

        res.json({ success: true, message: 'Status penukaran berhasil diupdate' });
    });
};

// DELETE TRANSAKSI PENUKARAN
exports.remove = (req, res) => {
    const { id } = req.params;
    const sql = 'DELETE FROM transaksi_penukaran WHERE id = ?';
    db.query(sql, [id], (err, result) => {
        if (err) return res.status(500).json({ success: false, message: err.message });

        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: 'Data tidak ditemukan' });
        }

        res.json({ success: true, message: 'Transaksi penukaran berhasil dihapus' });
    });
};
