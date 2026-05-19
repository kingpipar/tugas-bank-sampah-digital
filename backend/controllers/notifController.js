const { db } = require('../config/firebaseConfig');

const COLLECTION = 'notifications';

// GET ALL NOTIFICATIONS
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

// CREATE NOTIFICATION
exports.create = async (req, res) => {
    try {
        if (!db) return res.status(503).json({ error: 'Firebase belum dikonfigurasi' });

        const { title, message, type } = req.body;

        if (!title || !message) {
            return res.status(400).json({ success: false, message: 'Title dan message wajib diisi' });
        }

        const docRef = await db.collection(COLLECTION).add({
            title,
            message,
            type: type || 'info',
            created_at: new Date().toISOString()
        });

        res.status(201).json({ success: true, message: 'Notifikasi berhasil dibuat', id: docRef.id });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};