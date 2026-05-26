const { db } = require('../config/firebaseConfig');

const COLLECTION = 'pickup_requests';

// GET ALL PICKUP REQUESTS
exports.getAll = async (req, res) => {
    try {
        if (!db) return res.status(503).json({ error: 'Firebase belum dikonfigurasi' });

        const snapshot = await db.collection(COLLECTION).orderBy('created_at', 'desc').get();
        const data = [];
        snapshot.forEach(doc => {
            data.push({ id: doc.id, ...doc.data() });
        });
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// CREATE PICKUP REQUEST
exports.create = async (req, res) => {
    try {
        if (!db) return res.status(503).json({ error: 'Firebase belum dikonfigurasi' });

        const { nama_warga, alamat, jenis_sampah, estimasi_berat, tanggal_jemput, catatan } = req.body;

        if (!nama_warga || !alamat) {
            return res.status(400).json({ success: false, message: 'Data tidak lengkap' });
        }

        const docRef = await db.collection(COLLECTION).add({
            nama_warga,
            alamat,
            jenis_sampah: jenis_sampah || '',
            estimasi_berat: parseFloat(estimasi_berat) || 0,
            tanggal_jemput: tanggal_jemput || '',
            catatan: catatan || '',
            status: 'Menunggu',
            created_at: new Date().toISOString()
        });

        res.status(201).json({ success: true, message: 'Request penjemputan berhasil dibuat', id: docRef.id });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// UPDATE STATUS PICKUP REQUEST
exports.update = async (req, res) => {
    try {
        if (!db) return res.status(503).json({ error: 'Firebase belum dikonfigurasi' });

        const { id } = req.params;
        const { status } = req.body;

        if (!status) {
            return res.status(400).json({ success: false, message: 'Status wajib diisi' });
        }

        await db.collection(COLLECTION).doc(id).update({ status });
        res.json({ success: true, message: 'Status request berhasil diupdate' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// DELETE PICKUP REQUEST
exports.remove = async (req, res) => {
    try {
        if (!db) return res.status(503).json({ error: 'Firebase belum dikonfigurasi' });

        const { id } = req.params;
        await db.collection(COLLECTION).doc(id).delete();
        res.json({ success: true, message: 'Request berhasil dihapus' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
