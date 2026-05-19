const db = require('../config/sqlConfig');

// LOGIN
exports.login = (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ success: false, message: 'Email dan password wajib diisi' });
    }

    const sql = 'SELECT * FROM users WHERE email = ? AND password = ?';
    db.query(sql, [email, password], (err, results) => {
        if (err) return res.status(500).json({ success: false, message: 'Server Error' });

        if (results.length > 0) {
            const user = results[0];
            res.json({
                success: true,
                message: 'Login berhasil',
                user: { id: user.id, nama: user.nama, email: user.email, role: user.role }
            });
        } else {
            res.status(401).json({ success: false, message: 'Email atau password salah!' });
        }
    });
};

// UPDATE PROFIL
exports.updateProfile = (req, res) => {
    const { id, nama, email } = req.body;

    if (!id || !nama || !email) {
        return res.status(400).json({ success: false, message: 'Data tidak lengkap' });
    }

    const sql = 'UPDATE users SET nama = ?, email = ? WHERE id = ?';
    db.query(sql, [nama, email, id], (err, result) => {
        if (err) return res.status(500).json({ success: false, message: err.message });

        if (result.affectedRows > 0) {
            res.json({ success: true, message: 'Profil berhasil diperbarui' });
        } else {
            res.status(404).json({ success: false, message: 'User tidak ditemukan' });
        }
    });
};

// GANTI PASSWORD
exports.changePassword = (req, res) => {
    const { id, old_password, new_password } = req.body;

    if (!id || !old_password || !new_password) {
        return res.status(400).json({ success: false, message: 'Data tidak lengkap' });
    }

    // Cek password lama
    const sqlCheck = 'SELECT password FROM users WHERE id = ?';
    db.query(sqlCheck, [id], (err, results) => {
        if (err) return res.status(500).json({ success: false, message: 'Server Error' });

        if (results.length === 0) {
            return res.status(404).json({ success: false, message: 'User tidak ditemukan' });
        }

        if (results[0].password !== old_password) {
            return res.status(400).json({ success: false, message: 'Password lama salah' });
        }

        // Update password baru
        const sqlUpdate = 'UPDATE users SET password = ? WHERE id = ?';
        db.query(sqlUpdate, [new_password, id], (err2, result) => {
            if (err2) return res.status(500).json({ success: false, message: err2.message });

            res.json({ success: true, message: 'Password berhasil diubah' });
        });
    });
};