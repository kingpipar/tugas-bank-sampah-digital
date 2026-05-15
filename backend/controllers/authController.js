const db = require('../config/sqlConfig');

// FUNGSI LOGIN
exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;
        if (!email || !password) {
            return res.status(400).json({ success: false, message: 'Email dan password wajib diisi' });
        }

        const [result] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
        if (result.length === 0) {
            return res.status(404).json({ success: false, message: 'User tidak ditemukan' });
        }

        const user = result[0];
        if (password !== user.password) {
            return res.status(400).json({ success: false, message: 'Password salah' });
        }

        res.json({
            success: true,
            message: 'Login berhasil',
            user: { id: user.id, nama: user.nama, email: user.email, role: user.role }
        });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error' });
    }
};

// FUNGSI UPDATE PROFIL (Simpan ke Database)
exports.updateProfile = async (req, res) => {
    const { id, nama, email } = req.body;
    try {
        const [result] = await db.query('UPDATE users SET nama = ?, email = ? WHERE id = ?', [nama, email, id]);
        if (result.affectedRows > 0) {
            res.json({ success: true, message: 'Profil berhasil diperbarui' });
        } else {
            res.status(404).json({ success: false, message: 'User tidak ditemukan' });
        }
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};