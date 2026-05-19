require('dotenv').config();

const express = require('express');
const cors = require('cors');
const db = require('./db');

const app = express();

app.use(cors());
app.use(express.json());

/*
==================================================
TEST API
==================================================
*/

app.get('/', (req, res) => {
  res.json({
    message: 'Backend Bank Sampah berjalan',
  });
});

/*
==================================================
API ROUTES (prefix /api — sesuai Flutter AppConstants.baseUrl)
==================================================
*/

app.get('/api', (req, res) => {
  res.json({
    message: 'Backend Bank Sampah API berjalan',
  });
});

/*
==================================================
SYNC USER FIREBASE → MYSQL
==================================================
*/

app.post('/api/sync-user', async (req, res) => {
  try {

    console.log('Sync user request:', req.body);
    const { uid, email, nama, password } = req.body;

    if (!uid || !email) {
      return res.status(400).json({
        message: 'uid dan email wajib diisi',
      });
    }

    // cek user sudah ada?
    const [rows] = await db.query(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );
    

    if (rows.length > 0) {
      const mysqlUserId = rows[0].id;

      // update firebase_uid + password
      await db.query(
        `UPDATE users 
        SET firebase_uid = ?,
            password = ?
        WHERE email = ?`,
        [uid, password ?? null, email]
      );

      return res.json({
        message: 'User berhasil diupdate',
        id: mysqlUserId,
      });
    }

    // insert user baru
    const [insertResult] = await db.query(
      `INSERT INTO users 
      (nama, email, firebase_uid, role, password)
      VALUES (?, ?, ?, ?, ?)`,
      [nama ?? 'Warga', email, uid, 'warga', password ?? null]
    );

    res.json({
      message: 'User berhasil ditambahkan',
      id: insertResult.insertId,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: 'Server error',
      error: error.message,
    });
  }
});

/*
==================================================
CREATE REQUEST JEMPUT
==================================================
*/

app.post('/api/request-jemput', async (req, res) => {
  try {
    const {
      nama_warga,
      alamat,
      jenis_sampah,
      estimasi_berat,
      tanggal_jemput,
      catatan,
      user_id,
    } = req.body;

    if (!nama_warga || !user_id) {
      return res.status(400).json({
        message: 'nama_warga dan user_id wajib',
      });
    }

    await db.query(
      `INSERT INTO request_jemput
      (
        nama_warga,
        alamat,
        jenis_sampah,
        estimasi_berat,
        tanggal_jemput,
        catatan,
        status,
        user_id
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        nama_warga,
        alamat,
        jenis_sampah,
        estimasi_berat,
        tanggal_jemput,
        catatan,
        'Menunggu',
        user_id,
      ]
    );

    res.json({
      message: 'Request jemput berhasil dibuat',
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: 'Server error',
      error: error.message,
    });
  }
});

app.listen(process.env.PORT, () => {
  console.log(
    `Server berjalan di port ${process.env.PORT}`
  );
});