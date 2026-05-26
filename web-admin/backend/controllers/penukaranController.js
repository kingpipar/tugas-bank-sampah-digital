const db = require('../config/sqlConfig');

// Get All History Penukaran
const getAllPenukaran = async (req, res) => {
    try {
        const query = `
            SELECT t.id, t.nama_warga, t.jenis_penukaran, k.nama_sembako, t.poin_ditukar, t.tanggal_tukar 
            FROM transaksi_penukaran t
            LEFT JOIN katalog_sembako k ON t.id_sembako = k.id
            ORDER BY t.tanggal_tukar DESC
        `;
        const [rows] = await db.query(query);
        res.json(rows);
    } catch (error) {
        res.status(500).json({ message: "Gagal mengambil data transaksi penukaran", error });
    }
};

// Catat Transaksi Penukaran Baru (Mencairkan poin)
const addPenukaran = async (req, res) => {
    const { nama_warga, jenis_penukaran, id_sembako, poin_ditukar } = req.body;
    try {
        // Jalankan perintah insert transaksi
        await db.query(
            'INSERT INTO transaksi_penukaran (nama_warga, jenis_penukaran, id_sembako, poin_ditukar) VALUES (?, ?, ?, ?)', 
            [nama_warga, jenis_penukaran, id_sembako || null, poin_ditukar]
        );

        // POTONG STOK OTOMATIS: Jika jenis penukaran adalah Sembako, kurangi stoknya di tabel katalog
        if (jenis_penukaran === 'Sembako' && id_sembako) {
            await db.query('UPDATE katalog_sembako SET stok = stok - 1 WHERE id = ?', [id_sembako]);
        }

        res.status(201).json({ message: "Transaksi penukaran poin berhasil dicatat!" });
    } catch (error) {
        res.status(500).json({ message: "Gagal mencatat transaksi penukaran", error });
    }
};

module.exports = { getAllPenukaran, addPenukaran };
