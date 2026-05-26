const db = require('../config/sqlConfig');

// Get All Sembako
const getAllSembako = async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM katalog_sembako');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ message: "Gagal mengambil data sembako", error });
    }
};

// Add Sembako Baru (Create)
const addSembako = async (req, res) => {
    const { nama_sembako, harga_poin, stok } = req.body;
    try {
        await db.query(
            'INSERT INTO katalog_sembako (nama_sembako, harga_poin, stok) VALUES (?, ?, ?)', 
            [nama_sembako, harga_poin, stok]
        );
        res.status(201).json({ message: "Sembako baru berhasil ditambahkan ke katalog!" });
    } catch (error) {
        res.status(500).json({ message: "Gagal menambahkan sembako", error });
    }
};

// Update Sembako
const updateSembako = async (req, res) => {
    const { id } = req.params;
    const { nama_sembako, harga_poin, stok } = req.body;
    try {
        await db.query(
            'UPDATE katalog_sembako SET nama_sembako = ?, harga_poin = ?, stok = ? WHERE id = ?', 
            [nama_sembako, harga_poin, stok, id]
        );
        res.json({ message: "Data sembako berhasil diperbarui!" });
    } catch (error) {
        res.status(500).json({ message: "Gagal memperbarui sembako", error });
    }
};

// Delete Sembako
const deleteSembako = async (req, res) => {
    const { id } = req.params;
    try {
        await db.query('DELETE FROM katalog_sembako WHERE id = ?', [id]);
        res.json({ message: "Sembako berhasil dihapus dari katalog!" });
    } catch (error) {
        res.status(500).json({ message: "Gagal menghapus sembako", error });
    }
};

module.exports = { getAllSembako, addSembako, updateSembako, deleteSembako };