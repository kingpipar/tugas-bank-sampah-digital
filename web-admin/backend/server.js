require('dotenv').config();
const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const { db: firestoreDb } = require('./config/firebaseConfig');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors({ origin: '*' }));
app.use(express.json());

const db = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// ── Mengirim notifikasi ke Firestore ──────────────────────
// Menulis dokumen baru ke collection 'notifikasi' untuk ditampilkan
// secara real-time di aplikasi mobile warga.
function sendNotification({ userId, judul, pesan, tipeTrigger }) {
    if (!firestoreDb) {
        console.warn('⚠️ Firestore belum dikonfigurasi, notifikasi tidak terkirim');
        return;
    }

    firestoreDb.collection('notifikasi').add({
        user_id: userId,
        judul: judul,
        pesan: pesan,
        tipe_trigger: tipeTrigger,
        isRead: false,
        created_at: new Date()
    })
        .then(() => console.log(`✅ Notifikasi terkirim ke user ${userId}: ${judul}`))
        .catch(err => console.error('❌ Gagal kirim notifikasi:', err.message));
}

function syncExistingPricesToFirestore() {
    if (!firestoreDb) return;

    db.query('SELECT * FROM harga_sampah', (err, results) => {
        if (err) return console.error('Gagal membaca data harga sampah dari MySQL:', err.message);

        const batch = firestoreDb.batch();
        results.forEach(row => {
            const docRef = firestoreDb.collection('harga_sampah_realtime').doc(row.id.toString());
            batch.set(docRef, {
                id: row.id,
                kategori: row.kategori,
                nama_sampah: row.nama_sampah,
                harga_per_kg: row.harga_per_kg,
                poin_per_kg: row.poin_per_kg || 0,
                updated_at: new Date().toISOString()
            });
        });

        batch.commit()
            .then(() => console.log(`✅ Berhasil menyinkronkan ${results.length} data harga sampah ke Firestore`))
            .catch(fsErr => console.error('Gagal menyinkronkan data harga sampah ke Firestore:', fsErr.message));
    });
}

function syncExistingVouchersToFirestore() {
    if (!firestoreDb) return;

    db.query('SELECT * FROM voucher_reward', (err, results) => {
        if (err) return console.error('Gagal membaca data voucher dari MySQL:', err.message);

        const batch = firestoreDb.batch();
        results.forEach(row => {
            const docRef = firestoreDb.collection('voucher_reward_realtime').doc(row.id.toString());
            batch.set(docRef, {
                id: row.id,
                nama_voucher: row.nama_voucher,
                min_poin: row.min_poin,
                stok: row.stok,
                updated_at: new Date().toISOString()
            });
        });

        batch.commit()
            .then(() => console.log(`✅ Berhasil menyinkronkan ${results.length} data voucher ke Firestore`))
            .catch(fsErr => console.error('Gagal menyinkronkan data voucher ke Firestore:', fsErr.message));
    });
}

db.getConnection((err, connection) => {
    if (err) {
        console.error('❌ Gagal konek ke database:', err.message);
    } else {
        console.log(`✅ Database terhubung (bank_sampah_digital) di Port ${PORT}`);
        connection.release();
        syncExistingPricesToFirestore();
        syncExistingVouchersToFirestore();
    }
});

app.get('/api/stats', (req, res) => {
    const query = `
        SELECT 
            (SELECT COUNT(DISTINCT id_warga) FROM laporan_setoran) AS total_warga,
            (SELECT SUM(berat_kg) FROM laporan_setoran) AS total_berat,
            (SELECT SUM(total_harga) FROM laporan_setoran) AS total_kas,
            (SELECT COUNT(*) FROM request_jemput) AS total_jemput,
            (SELECT COUNT(*) FROM transaksi_penukaran) AS total_sembako
    `;

    db.query(query, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        const data = results[0] || {};
        res.json({
            total_warga: data.total_warga || 0,
            total_berat: data.total_berat || 0,
            total_kas: data.total_kas || 0,
            total_jemput: data.total_jemput || 0,
            total_sembako: data.total_sembako || 0
        });
    });
});

const getHargaHandler = (req, res) => {
    const sql = 'SELECT * FROM harga_sampah ORDER BY id DESC';
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
};
app.get('/api/harga', getHargaHandler);
app.get('/api/harga_sampah', getHargaHandler);

app.get('/api/harga/stats', (req, res) => {
    const sql = `
        SELECT 
            COUNT(DISTINCT kategori) AS total_kategori,
            MAX(harga_per_kg) AS harga_tertinggi,
            AVG(harga_per_kg) AS harga_rata_rata
        FROM harga_sampah
    `;
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        const data = results[0] || {};
        res.json({
            total_kategori: data.total_kategori || 0,
            harga_tertinggi: data.harga_tertinggi || 0,
            harga_rata_rata: Math.round(data.harga_rata_rata || 0)
        });
    });
});

app.post('/api/harga', (req, res) => {
    const { kategori, nama_sampah, harga_per_kg } = req.body;
    const poin = Math.floor(harga_per_kg / 10);
    const sql = 'INSERT INTO harga_sampah (kategori, nama_sampah, harga_per_kg, poin_per_kg) VALUES (?, ?, ?, ?)';
    db.query(sql, [kategori, nama_sampah, harga_per_kg, poin], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });

        // Sync to Firestore
        if (firestoreDb) {
            firestoreDb.collection('harga_sampah_realtime').doc(result.insertId.toString()).set({
                id: result.insertId,
                kategori,
                nama_sampah,
                harga_per_kg: parseInt(harga_per_kg),
                poin_per_kg: poin,
                updated_at: new Date().toISOString()
            }).catch(fsErr => console.error('Gagal sync ke Firestore:', fsErr.message));
        }

        res.status(201).json({ success: true, message: 'Data berhasil ditambahkan' });
    });
});

app.put('/api/harga/:id', (req, res) => {
    const { id } = req.params;
    const { kategori, nama_sampah, harga_per_kg } = req.body;
    const poin = Math.floor(harga_per_kg / 10);
    const sql = 'UPDATE harga_sampah SET kategori = ?, nama_sampah = ?, harga_per_kg = ?, poin_per_kg = ? WHERE id = ?';
    db.query(sql, [kategori, nama_sampah, harga_per_kg, poin, id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });

        // Sync to Firestore
        if (firestoreDb) {
            firestoreDb.collection('harga_sampah_realtime').doc(id.toString()).set({
                id: parseInt(id),
                kategori,
                nama_sampah,
                harga_per_kg: parseInt(harga_per_kg),
                poin_per_kg: poin,
                updated_at: new Date().toISOString()
            }, { merge: true }).catch(fsErr => console.error('Gagal sync ke Firestore:', fsErr.message));
        }

        res.json({ success: true, message: 'Data berhasil diperbarui' });
    });
});

app.delete('/api/harga/:id', (req, res) => {
    const { id } = req.params;
    const sql = 'DELETE FROM harga_sampah WHERE id = ?';
    db.query(sql, [id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });

        // Sync to Firestore
        if (firestoreDb) {
            firestoreDb.collection('harga_sampah_realtime').doc(id.toString()).delete()
                .catch(fsErr => console.error('Gagal delete sync ke Firestore:', fsErr.message));
        }

        res.json({ success: true, message: 'Data berhasil dihapus' });
    });
});

app.get('/api/laporan', (req, res) => {
    const sql = `
        SELECT l.id, COALESCE(u.nama, r.nama_warga) AS nama_warga, COALESCE(u.rt, r.rt) AS rt, COALESCE(u.rw, r.rw) AS rw,
               h.kategori, h.nama_sampah, l.berat_kg, l.total_harga, l.poin_didapat, l.id_request, l.tanggal_setor, r.catatan
        FROM laporan_setoran l
        LEFT JOIN users u ON l.id_warga = u.id
        LEFT JOIN request_jemput r ON l.id_request = r.id
        LEFT JOIN harga_sampah h ON l.id_sampah = h.id
        ORDER BY l.id DESC
    `;
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.post('/api/laporan', (req, res) => {
    const { id_warga, id_sampah, berat_kg, id_request } = req.body;
    const berat = parseFloat(berat_kg) || 0;
    db.query('SELECT harga_per_kg, poin_per_kg FROM harga_sampah WHERE id = ?', [id_sampah], (errH, rowsH) => {
        if (errH) return res.status(500).json({ error: errH.message });
        const harga = (rowsH && rowsH[0]) ? parseFloat(rowsH[0].harga_per_kg) || 0 : 0;
        const poin_per_kg = (rowsH && rowsH[0]) ? parseFloat(rowsH[0].poin_per_kg) || 0 : 0;
        const total_harga = Math.round(berat * harga);
        const poin_didapat = Math.round(berat * poin_per_kg);

        const insertSql = 'INSERT INTO laporan_setoran (id_sampah, berat_kg, total_harga, id_warga, id_request, poin_didapat) VALUES (?, ?, ?, ?, ?, ?)';
        const params = [id_sampah, berat, total_harga, id_warga || null, id_request || null, poin_didapat];
        db.query(insertSql, params, (errIns) => {
            if (errIns) return res.status(500).json({ error: errIns.message });
            // update user saldo_poin if we have id_warga
            if (id_warga && poin_didapat > 0) {
                db.query('UPDATE users SET saldo_poin = COALESCE(saldo_poin,0) + ? WHERE id = ?', [poin_didapat, id_warga], (errUpd) => {
                    if (errUpd) console.error('update saldo error', errUpd.message);
                });
            }
            res.status(201).json({ success: true, message: 'Laporan berhasil ditambahkan!' });
        });
    });
});

app.get('/api/penukaran', (req, res) => {
    const query = `
        SELECT t.id, t.nama_warga, t.jenis_penukaran, t.poin_ditukar, t.tanggal_tukar,
               v.nama_voucher
        FROM transaksi_penukaran t
        LEFT JOIN voucher_reward v ON t.id_voucher = v.id
        ORDER BY t.id DESC
    `;
    db.query(query, (err, results) => {
        if (err) {
            db.query('SELECT * FROM transaksi_penukaran ORDER BY id DESC', (err2, results2) => {
                if (err2) return res.status(500).json({ error: err2.message });
                res.json(results2);
            });
            return;
        }
        res.json(results);
    });
});

app.post('/api/penukaran', (req, res) => {
    const { id_warga, nama_warga, id_voucher, poin_ditukar, jenis_penukaran } = req.body;

    if (!id_warga || !id_voucher || !poin_ditukar) {
        return res.status(400).json({ success: false, message: 'Data penukaran tidak lengkap' });
    }

    // 1. Cek saldo poin warga
    db.query('SELECT saldo_poin, nama, email FROM users WHERE id = ?', [id_warga], (errUser, users) => {
        if (errUser) return res.status(500).json({ success: false, error: errUser.message });
        if (users.length === 0) return res.status(404).json({ success: false, message: 'Warga tidak ditemukan' });

        const user = users[0];
        const currentPoin = user.saldo_poin || 0;
        if (currentPoin < poin_ditukar) {
            return res.status(400).json({ success: false, message: 'Saldo poin Anda tidak mencukupi' });
        }

        // 2. Cek stok voucher
        db.query('SELECT stok, nama_voucher FROM voucher_reward WHERE id = ?', [id_voucher], (errVouch, vouchers) => {
            if (errVouch) return res.status(500).json({ success: false, error: errVouch.message });
            if (vouchers.length === 0) return res.status(404).json({ success: false, message: 'Voucher tidak ditemukan' });

            const voucher = vouchers[0];
            if (voucher.stok <= 0) {
                return res.status(400).json({ success: false, message: 'Stok voucher ini sudah habis' });
            }

            // 3. Masukkan transaksi penukaran ke MySQL
            const jenis = jenis_penukaran || (voucher.nama_voucher.toLowerCase().includes('dana') || voucher.nama_voucher.toLowerCase().includes('uang') ? 'Uang' : 'Sembako');
            const namaWargaFix = user.nama;

            db.query(
                'INSERT INTO transaksi_penukaran (nama_warga, jenis_penukaran, id_voucher, poin_ditukar, id_warga) VALUES (?, ?, ?, ?, ?)',
                [namaWargaFix, jenis, id_voucher, poin_ditukar, id_warga],
                (errIns, resultIns) => {
                    if (errIns) return res.status(500).json({ success: false, error: errIns.message });

                    // 4. Potong saldo poin warga di MySQL
                    db.query(
                        'UPDATE users SET saldo_poin = saldo_poin - ? WHERE id = ?',
                        [poin_ditukar, id_warga],
                        (errUpdUser) => {
                            if (errUpdUser) console.error('Gagal memotong poin warga:', errUpdUser.message);
                        }
                    );

                    // 5. Potong stok voucher di MySQL
                    const newStock = voucher.stok - 1;
                    db.query(
                        'UPDATE voucher_reward SET stok = ? WHERE id = ?',
                        [newStock, id_voucher],
                        (errUpdVouch) => {
                            if (errUpdVouch) {
                                console.error('Gagal mengurangi stok voucher di MySQL:', errUpdVouch.message);
                            } else {
                                // 6. Sync stok voucher ke Firestore
                                if (firestoreDb) {
                                    firestoreDb.collection('voucher_reward_realtime').doc(id_voucher.toString()).update({
                                        stok: newStock,
                                        updated_at: new Date().toISOString()
                                    }).then(() => {
                                        console.log(`✅ Berhasil menyinkronkan stok voucher ${id_voucher} ke Firestore`);
                                    }).catch(fsErr => {
                                        console.error('❌ Gagal sinkronisasi stok voucher ke Firestore:', fsErr.message);
                                    });
                                }
                            }
                        }
                    );

                    // 7. Sync saldo poin warga ke Firestore
                    if (firestoreDb && user.email) {
                        firestoreDb.collection('warga_realtime')
                            .where('email', '==', user.email)
                            .get()
                            .then(snapshot => {
                                if (!snapshot.empty) {
                                    snapshot.docs[0].ref.update({
                                        saldoPoin: currentPoin - poin_ditukar
                                    }).then(() => {
                                        console.log(`✅ Berhasil menyinkronkan saldo poin user ${id_warga} ke Firestore`);
                                    });
                                }
                            })
                            .catch(fsErr => {
                                console.error('❌ Gagal sinkronisasi saldo user ke Firestore:', fsErr.message);
                            });
                    }

                    res.status(201).json({
                        success: true,
                        message: `Berhasil menukarkan voucher "${voucher.nama_voucher}"!`,
                        transactionId: resultIns.insertId,
                        newSaldoPoin: currentPoin - poin_ditukar
                    });
                }
            );
        });
    });
});

const createRequestJemputHandler = (req, res) => {
    const {
        nama_warga,
        jenis_sampah,
        estimasi_berat,
        tanggal_jemput,
        catatan,
        user_id,
        id_sampah
    } = req.body;

    if (!user_id) {
        return res.status(400).json({ success: false, message: 'User wajib diisi' });
    }

    if (!jenis_sampah) {
        return res.status(400).json({ success: false, message: 'Jenis sampah wajib diisi' });
    }

    const berat = parseFloat(estimasi_berat);
    if (!berat || berat <= 0) {
        return res.status(400).json({ success: false, message: 'Estimasi berat tidak valid' });
    }

    const insertRequest = (user, sampahId) => {
        const sql = `
            INSERT INTO request_jemput
                (nama_warga, rt, rw, jenis_sampah, estimasi_berat, tanggal_jemput, catatan, status, id_warga, id_sampah)
            VALUES (?, ?, ?, ?, ?, ?, ?, 'menunggu', ?, ?)
        `;
        const values = [
            nama_warga || user.nama || '',
            user.rt || null,
            user.rw || null,
            jenis_sampah,
            berat,
            tanggal_jemput || new Date().toISOString().slice(0, 10),
            catatan || '',
            user.id,
            sampahId || null
        ];

        db.query(sql, values, (err, result) => {
            if (err) return res.status(500).json({ success: false, message: err.message });
            res.status(201).json({
                success: true,
                message: 'Request jemput berhasil dibuat',
                id: result.insertId
            });

            // tipe_trigger 1: Request berhasil dibuat
            sendNotification({
                userId: user.id,
                judul: 'Request Berhasil!',
                pesan: `Request penjemputan sampah ${jenis_sampah}mu berhasil dibuat. Menunggu konfirmasi admin.`,
                tipeTrigger: 1
            });
        });
    };

    db.query('SELECT id, nama, rt, rw FROM users WHERE id = ?', [user_id], (errUser, users) => {
        if (errUser) return res.status(500).json({ success: false, message: errUser.message });
        if (!users || users.length === 0) {
            return res.status(404).json({ success: false, message: 'User tidak ditemukan' });
        }

        const user = users[0];
        if (id_sampah) {
            return insertRequest(user, id_sampah);
        }

        db.query('SELECT id FROM harga_sampah WHERE nama_sampah = ? LIMIT 1', [jenis_sampah], (errSampah, sampahRows) => {
            if (errSampah) return res.status(500).json({ success: false, message: errSampah.message });
            insertRequest(user, sampahRows && sampahRows[0] ? sampahRows[0].id : null);
        });
    });
};

app.post('/api/request_jemput', createRequestJemputHandler);
app.post('/api/request-jemput', createRequestJemputHandler);

app.get('/api/request_jemput', (req, res) => {
    const sql = `
        SELECT r.*, 
               COALESCE(u.nama, r.nama_warga) AS nama_warga,
               COALESCE(h.nama_sampah, r.jenis_sampah) AS jenis_sampah,
               h.poin_per_kg,
               (r.estimasi_berat * h.poin_per_kg) AS poin_didapat
        FROM request_jemput r
        LEFT JOIN users u ON r.id_warga = u.id
        LEFT JOIN harga_sampah h ON r.id_sampah = h.id
        ORDER BY r.id DESC
    `;
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.put('/api/request_jemput/:id', (req, res) => {
    const { id } = req.params;
    let updates = [];
    let values = [];

    if (req.body.status) {
        updates.push('status = ?');
        values.push(req.body.status);
    }
    if (req.body.nama_warga) {
        updates.push('nama_warga = ?');
        values.push(req.body.nama_warga);
    }
    if (req.body.rt !== undefined) {
        updates.push('rt = ?');
        values.push(req.body.rt);
    }
    if (req.body.rw !== undefined) {
        updates.push('rw = ?');
        values.push(req.body.rw);
    }
    if (req.body.catatan !== undefined) {
        updates.push('catatan = ?');
        values.push(req.body.catatan);
    }

    if (updates.length === 0) return res.json({ success: true });

    values.push(id);
    const sql = `UPDATE request_jemput SET ${updates.join(', ')} WHERE id = ?`;

    db.query(sql, values, (err) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true, message: 'Request berhasil diperbarui' });

        // Sync status to Firestore
        if (firestoreDb && req.body.status) {
            firestoreDb.collection('request_jemput_realtime')
                .doc(id.toString())
                .update({
                    status: req.body.status.toLowerCase()
                })
                .then(() => console.log(`✅ Berhasil menyinkronkan status request ${id} ke Firestore`))
                .catch(fsErr => console.error('❌ Gagal sinkronisasi status request ke Firestore:', fsErr.message));
        }

        // ── NOTIFIKASI + AUTO-LAPORAN ───────────────────────────────
        try {
            const statusBaru = (req.body.status || '').toLowerCase();

            // Ambil detail request untuk notifikasi
            db.query('SELECT * FROM request_jemput WHERE id = ?', [id], (errReq, rowsReq) => {
                if (errReq || !rowsReq || !rowsReq.length) return;
                const reqRow = rowsReq[0];
                const id_warga = reqRow.id_warga || null;

                // tipe_trigger 2: Request Diterima
                if (statusBaru === 'diterima' && id_warga) {
                    sendNotification({
                        userId: id_warga,
                        judul: 'Request Diterima!',
                        pesan: 'Sudah di-ACC oleh admin di website. Kurir akan segera meluncur ke rumahmu.',
                        tipeTrigger: 2
                    });
                }

                // tipe_trigger 3 + 4: Penjemputan Selesai + Poin
                if (statusBaru === 'selesai') {
                    if (id_warga) {
                        sendNotification({
                            userId: id_warga,
                            judul: 'Penjemputan Selesai',
                            pesan: 'Sampahmu sudah selesai dijemput oleh petugas.',
                            tipeTrigger: 3
                        });
                    }

                    // Auto-create laporan_setoran
                    db.query('SELECT COUNT(*) AS c FROM laporan_setoran WHERE id_request = ?', [id], (errCheck, rowsCheck) => {
                        if (errCheck) return console.error('cek laporan error', errCheck.message);
                        if (rowsCheck && rowsCheck[0] && rowsCheck[0].c > 0) return;
                        const berat = parseFloat(reqRow.estimasi_berat) || 0;
                        const id_sampah = reqRow.id_sampah || null;
                        const id_warga = reqRow.id_warga || null;
                        if (!id_sampah) {
                            const insertSql0 = 'INSERT INTO laporan_setoran (id_sampah, berat_kg, total_harga, id_warga, id_request, poin_didapat) VALUES (?, ?, ?, ?, ?, ?)';
                            db.query(insertSql0, [null, berat, 0, id_warga, id, 0], (errIns0) => {
                                if (errIns0) return console.error('insert laporan error', errIns0.message);
                            });
                        } else {
                            db.query('SELECT harga_per_kg, poin_per_kg FROM harga_sampah WHERE id = ?', [id_sampah], (errH, rowsH) => {
                                if (errH) return console.error('get harga error', errH.message);
                                const harga = (rowsH && rowsH[0]) ? parseFloat(rowsH[0].harga_per_kg) || 0 : 0;
                                const poin_per_kg = (rowsH && rowsH[0]) ? parseFloat(rowsH[0].poin_per_kg) || 0 : 0;
                                const total_harga = Math.round(berat * harga);
                                const poin_didapat = Math.round(berat * poin_per_kg);

                                const insertSql = 'INSERT INTO laporan_setoran (id_sampah, berat_kg, total_harga, id_warga, id_request, poin_didapat) VALUES (?, ?, ?, ?, ?, ?)';
                                const params = [id_sampah, berat, total_harga, id_warga, id, poin_didapat];
                                db.query(insertSql, params, (errIns) => {
                                    if (errIns) return console.error('insert laporan error', errIns.message);
                                    if (id_warga && poin_didapat > 0) {
                                        db.query('UPDATE users SET saldo_poin = COALESCE(saldo_poin,0) + ? WHERE id = ?', [poin_didapat, id_warga], (errUpd) => {
                                            if (errUpd) return console.error('update saldo error', errUpd.message);
                                        });

                                        // tipe_trigger 4: Saldo Poin Bertambah
                                        sendNotification({
                                            userId: id_warga,
                                            judul: 'Saldo Poin Bertambah!',
                                            pesan: 'Kamu mendapatkan saldo poin sebesar ' + poin_didapat + ' dari setoran sampah terakhir.',
                                            tipeTrigger: 4
                                        });
                                    }
                                });
                            });
                        }
                    });
                }
            });
        } catch (e) {
            console.error('post-update automation error', e.message);
        }
    });
});

app.delete('/api/request_jemput/:id', (req, res) => {
    db.query('DELETE FROM request_jemput WHERE id = ?', [req.params.id], (err) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true, message: 'Request dihapus' });
    });
});

app.post('/api/login', (req, res) => {
    const { email, password } = req.body;
    db.query('SELECT * FROM users WHERE email = ?', [email], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.length === 0 || results[0].password !== password) {
            return res.status(401).json({ success: false, message: 'Email atau password salah!' });
        }
        if (results[0].role !== 'admin') {
            return res.status(403).json({ success: false, message: 'Akses ditolak! Hanya Admin yang bisa masuk.' });
        }
        res.json({ success: true, user: results[0] });
    });
});

app.put('/api/update-profile', (req, res) => {
    const { id, nama, email } = req.body;
    const sql = 'UPDATE users SET nama = ?, email = ? WHERE id = ?';
    db.query(sql, [nama, email, id], (err, result) => {
        if (err) return res.status(500).json({ success: false, message: err.message });
        res.json({ success: true, message: 'Profil berhasil diperbarui' });
    });
});

app.put('/api/change-password', (req, res) => {
    const { id, oldPassword, newPassword } = req.body;
    db.query('SELECT password FROM users WHERE id = ?', [id], (err, results) => {
        if (err) return res.status(500).json({ success: false, message: err.message });
        if (results.length === 0 || results[0].password !== oldPassword) {
            return res.status(400).json({ success: false, message: 'Password lama salah!' });
        }
        db.query('UPDATE users SET password = ? WHERE id = ?', [newPassword, id], (err2) => {
            if (err2) return res.status(500).json({ success: false, message: err2.message });
            res.json({ success: true, message: 'Password berhasil diganti!' });
        });
    });
});

const getSembakoHandler = (req, res) => {
    db.query('SELECT * FROM voucher_reward ORDER BY id DESC', (err, results) => {
        if (err) return res.status(500).json({ error: err.message });

        const mappedResults = results.map(item => ({
            id: item.id,
            nama_voucher: item.nama_voucher,
            min_poin: item.min_poin,
            nama_sembako: item.nama_voucher,
            harga_poin: item.min_poin,
            stok: item.stok
        }));
        res.json(mappedResults);
    });
};
app.get('/api/sembako', getSembakoHandler);
app.get('/api/voucher', getSembakoHandler);
app.get('/api/voucher_reward', getSembakoHandler);

app.post('/api/voucher_reward', (req, res) => {
    const { nama_voucher, min_poin, stok } = req.body;
    const sql = 'INSERT INTO voucher_reward (nama_voucher, min_poin, stok) VALUES (?, ?, ?)';
    db.query(sql, [nama_voucher, parseInt(min_poin), parseInt(stok)], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });

        // Sync to Firestore
        if (firestoreDb) {
            firestoreDb.collection('voucher_reward_realtime').doc(result.insertId.toString()).set({
                id: result.insertId,
                nama_voucher,
                min_poin: parseInt(min_poin),
                stok: parseInt(stok),
                updated_at: new Date().toISOString()
            }).catch(fsErr => console.error('Gagal sync voucher ke Firestore:', fsErr.message));
        }

        // Kirim notifikasi ke semua warga
        db.query('SELECT id FROM users WHERE role = "warga"', (errUsers, wargaList) => {
            if (!errUsers && wargaList) {
                wargaList.forEach(w => {
                    sendNotification({
                        userId: w.id,
                        judul: 'Voucher Baru Tersedia! 🎉',
                        pesan: `Admin baru saja menambahkan voucher '${nama_voucher}'. Yuk tukarkan poinmu sebelum kehabisan!`,
                        tipeTrigger: 5
                    });
                });
            }
        });

        res.status(201).json({ success: true, message: 'Voucher berhasil ditambahkan' });
    });
});

app.put('/api/voucher_reward/:id', (req, res) => {
    const { id } = req.params;
    const { nama_voucher, min_poin, stok } = req.body;
    const sql = 'UPDATE voucher_reward SET nama_voucher = ?, min_poin = ?, stok = ? WHERE id = ?';
    db.query(sql, [nama_voucher, parseInt(min_poin), parseInt(stok), id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });

        // Sync to Firestore
        if (firestoreDb) {
            firestoreDb.collection('voucher_reward_realtime').doc(id.toString()).set({
                id: parseInt(id),
                nama_voucher,
                min_poin: parseInt(min_poin),
                stok: parseInt(stok),
                updated_at: new Date().toISOString()
            }, { merge: true }).catch(fsErr => console.error('Gagal sync voucher ke Firestore:', fsErr.message));
        }

        res.json({ success: true, message: 'Voucher berhasil diperbarui' });
    });
});

app.delete('/api/voucher_reward/:id', (req, res) => {
    const { id } = req.params;
    const sql = 'DELETE FROM voucher_reward WHERE id = ?';
    db.query(sql, [id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });

        // Sync to Firestore
        if (firestoreDb) {
            firestoreDb.collection('voucher_reward_realtime').doc(id.toString()).delete()
                .catch(fsErr => console.error('Gagal delete sync voucher ke Firestore:', fsErr.message));
        }

        res.json({ success: true, message: 'Voucher berhasil dihapus' });
    });
});

app.get('/api/notifikasi', (req, res) => {
    const { userId } = req.params;

    res.json([]);
});

app.get('/api/users', (req, res) => {
    db.query('SELECT * FROM users WHERE role="warga" ORDER BY id ASC', (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.get('/api/users/stats', (req, res) => {
    db.query(`
        SELECT 
            COUNT(*) AS total,
            SUM(jenis_kelamin = 'Laki-laki') AS laki,
            SUM(jenis_kelamin = 'Perempuan') AS perempuan
        FROM users WHERE role="warga"
    `, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results[0]);
    });
});

app.post('/api/sync-user', (req, res) => {
    const { nama, email, password, rt, rw, jenis_kelamin } = req.body;

    if (!email) {
        return res.status(400).json({ success: false, message: 'Email wajib diisi' });
    }

    db.query('SELECT * FROM users WHERE email = ?', [email], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });

        if (results.length > 0) {
            // User sudah ada di database MySQL, kembalikan data user tersebut
            const user = results[0];
            return res.json({
                success: true,
                id: user.id,
                nama: user.nama,
                email: user.email,
                saldo_poin: user.saldo_poin || 0
            });
        } else {
            // User belum ada di MySQL, tambahkan baru
            const namaUser = nama || 'Warga Baru';
            const passUser = password || '123456'; // Default password jika kosong

            db.query(
                'INSERT INTO users (nama, email, password, role, rt, rw, jenis_kelamin, saldo_poin) VALUES (?, ?, ?, "warga", ?, ?, ?, 0)',
                [namaUser, email, passUser, rt || null, rw || null, jenis_kelamin || null],
                (errIns, resultIns) => {
                    if (errIns) return res.status(500).json({ error: errIns.message });

                    res.status(201).json({
                        success: true,
                        id: resultIns.insertId,
                        nama: namaUser,
                        email: email,
                        saldo_poin: 0
                    });
                }
            );
        }
    });
});

app.post('/api/users', (req, res) => {
    const { nama, email, password, rt, rw, jenis_kelamin } = req.body;
    db.query('INSERT INTO users (nama, email, password, rt, rw, jenis_kelamin, role) VALUES (?, ?, ?, ?, ?, ?, "warga")',
        [nama, email, password, rt, rw, jenis_kelamin], (err) => {
            if (err) return res.status(500).json({ error: err.message });
            res.status(201).json({ success: true });
        });
});

app.put('/api/users/:id', (req, res) => {
    const { nama, email, password, rt, rw, jenis_kelamin } = req.body;
    let sql = 'UPDATE users SET nama=?, email=?, rt=?, rw=?, jenis_kelamin=?';
    let params = [nama, email, rt, rw, jenis_kelamin];

    if (password) {
        sql += ', password=?';
        params.push(password);
    }

    sql += ' WHERE id=? AND role="warga"';
    params.push(req.params.id);

    db.query(sql, params, (err) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true });
    });
});

app.delete('/api/users/:id', (req, res) => {
    db.query('DELETE FROM users WHERE id=? AND role="warga"', [req.params.id], (err) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true });
    });
});

// Ambil saldo poin warga berdasarkan MySQL user ID
app.get('/api/saldo/:userId', (req, res) => {
    const { userId } = req.params;
    db.query('SELECT saldo_poin FROM users WHERE id = ?', [userId], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.length === 0) return res.status(404).json({ message: 'User tidak ditemukan' });
        res.json({ saldo_poin: results[0].saldo_poin || 0 });
    });
});

// Ambil riwayat poin warga: setoran sampah + penukaran voucher
app.get('/api/transaksi/:userId', (req, res) => {
    const { userId } = req.params;

    // Gabungkan setoran sampah (poin masuk) dan penukaran (poin keluar)
    const sql = `
        SELECT
            id,
            'Setor Sampah' AS jenis,
            poin_didapat AS jumlah_poin,
            CONCAT('Setor ', berat_kg, 'kg sampah') AS keterangan,
            tanggal_setor AS tanggal
        FROM laporan_setoran
        WHERE id_warga = ? AND poin_didapat > 0

        UNION ALL

        SELECT
            t.id,
            'Tukar Voucher' AS jenis,
            -(t.poin_ditukar) AS jumlah_poin,
            CONCAT('Tukar ', t.poin_ditukar, ' poin → ', COALESCE(v.nama_voucher, t.jenis_penukaran)) AS keterangan,
            t.tanggal_tukar AS tanggal
        FROM transaksi_penukaran t
        LEFT JOIN voucher_reward v ON t.id_voucher = v.id
        WHERE t.id_warga = ?

        ORDER BY tanggal DESC
        LIMIT 50
    `;

    db.query(sql, [userId, userId], (err, results) => {
        if (err) {
            // Fallback: hanya setoran jika tabel transaksi_penukaran belum ada id_warga
            const fallbackSql = `
                SELECT id, 'Setor Sampah' AS jenis, poin_didapat AS jumlah_poin,
                       CONCAT('Setor ', berat_kg, 'kg sampah') AS keterangan, tanggal_setor AS tanggal
                FROM laporan_setoran
                WHERE id_warga = ?
                ORDER BY tanggal_setor DESC LIMIT 50
            `;
            db.query(fallbackSql, [userId], (err2, results2) => {
                if (err2) return res.status(500).json({ error: err2.message });
                res.json(results2);
            });
            return;
        }
        res.json(results);
    });
});

app.listen(PORT, () => {
    console.log(`🚀 Server Backend berjalan mulus di http://localhost:${PORT}`);
});
