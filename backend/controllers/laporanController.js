const db = require('../config/sqlConfig');

// GET ALL LAPORAN (JOIN harga_sampah)
exports.getAll = (req, res) => {
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
};

// CREATE LAPORAN SETORAN
exports.create = (req, res) => {
    const { tanggal_setor, nama_warga, id_sampah, berat_kg, total_harga } = req.body;

    if (!nama_warga || !id_sampah || !berat_kg) {
        return res.status(400).json({ success: false, message: 'Data tidak lengkap' });
    }

    const sql = `INSERT INTO laporan_setoran (tanggal_setor, nama_warga, id_sampah, berat_kg, total_harga) VALUES (?, ?, ?, ?, ?)`;
    db.query(sql, [tanggal_setor || new Date(), nama_warga, parseInt(id_sampah), parseFloat(berat_kg), parseInt(total_harga) || 0], (err, result) => {
        if (err) return res.status(500).json({ success: false, error: err.sqlMessage || err.message });
        res.status(201).json({ success: true, message: 'Berhasil menyimpan setoran!', id: result.insertId });
    });
};

// DELETE LAPORAN SETORAN
exports.remove = (req, res) => {
    const { id } = req.params;
    const sql = 'DELETE FROM laporan_setoran WHERE id = ?';
    db.query(sql, [id], (err, result) => {
        if (err) return res.status(500).json({ success: false, message: err.message });

        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: 'Data tidak ditemukan' });
        }

        res.json({ success: true, message: 'Laporan berhasil dihapus' });
    });
};

// GET DASHBOARD STATS
exports.getStats = (req, res) => {
    const sql = `
        SELECT
            (SELECT COUNT(DISTINCT nama_warga) FROM laporan_setoran) AS total_warga,
            (SELECT COALESCE(SUM(berat_kg),0) FROM laporan_setoran) AS total_berat,
            (SELECT COALESCE(SUM(total_harga),0) FROM laporan_setoran) AS total_kas,
            (SELECT COUNT(*) FROM request_jemput WHERE status != 'Selesai') AS total_jemput
    `;
    db.query(sql, (err, result) => {
        if (err) return res.status(500).json({ success: false, error: err.message });

        res.json({
            total_warga: result[0].total_warga || 0,
            total_berat: result[0].total_berat || 0,
            total_kas: result[0].total_kas || 0,
            total_jemput: result[0].total_jemput || 0
        });
    });
};