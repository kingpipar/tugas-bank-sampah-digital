# 📱 Tugas Akhir : Praktikum Teknologi Cloud Computing IF-C
# ♻️ Bank Sampah Digital

---

# 👥 Anggota Kelompok

1. Cendikia Permata Dewanti / 123230011
2. Al Faarray / 123230109
3. Vincentius Ariell Sorongan  / 123230131
4. Dwi Suci Andari / 123230192

---

![Flutter](https://img.shields.io/badge/Mobile-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Express.js](https://img.shields.io/badge/Backend-Express.js-404D59?style=for-the-badge)
![MySQL](https://img.shields.io/badge/Database-MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![MongoDB](https://img.shields.io/badge/Database-MongoDB-4EA94B?style=for-the-badge&logo=mongodb&logoColor=white)
![GCP](https://img.shields.io/badge/Cloud-GCP_Ubuntu_VM-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)

---

## ✨ Fitur Utama

Sistem ini dibagi menjadi dua platform utama yang melayani *role* pengguna yang berbeda:

### 📱 1. Aplikasi Mobile (User / Warga)
Aplikasi berbasis **Flutter** yang didesain untuk kemudahan warga dalam mengelola sampah mereka.
- **Request Penjemputan Real-time:** Warga dapat meminta penjemputan sampah dengan mengirimkan koordinat lokasi.
- **Cek Saldo Poin:** Pantau total poin yang didapat dari hasil konversi sampah secara *real-time*.
- **Riwayat Transaksi:** Melihat histori setoran sampah dan penukaran poin (sembako/uang).
- **Notifikasi Live:** Mendapatkan *update* status penjemputan dan penambahan saldo.

### 💻 2. Aplikasi Web Admin & Backend API (Admin / Pengepul)
Sistem berbasis **Express.js / PHP MVC** yang berfungsi sebagai *dashboard* operasional dan penyedia layanan API.
- **Manajemen Kategori & Harga:** Mengatur harga beli sampah anorganik per kilogram.
- **Penerimaan Request Penjemputan:** Mengelola antrean permintaan penjemputan dari warga.
- **Input Setoran Warga:** Mengonversi berat sampah fisik menjadi poin ke akun warga secara otomatis.
- **Laporan Harian:** Menggabungkan data transaksi dan total sampah yang terkumpul.

---

## 🏗️ Arsitektur Sistem

Proyek ini menggunakan pendekatan **Polyglot Persistence** untuk mengoptimalkan performa sesuai kebutuhan data:

1. **MySQL (Relational Data)**
   - Menangani data transaksional yang membutuhkan integritas tinggi (ACID Compliance).
   - Menyimpan tabel: `users`, `kategori_sampah`, `saldo_poin`, `setoran_sampah`, dan `transaksi_penukaran`.
2. **MongoDB (NoSQL Document Data)**
   - Menangani data yang dinamis, tidak terstruktur ketat, dan membutuhkan operasi I/O cepat.
   - Menyimpan *collections*: `pickup_requests` (koordinat lokasi dinamis) dan `notifications`.
3. **Google Cloud Platform (GCP)**
   - Keseluruhan *backend* dan *database* berjalan secara *native* di dalam 1 *instance* **Ubuntu VM**.

---

## 📁 Struktur Folder Monorepo

Repository ini menggunakan satu direktori utama untuk mempermudah manajemen versi antar *platform*:

```
bank-sampah-digital/
├── mobile-warga/               
│   ├── lib/
│   │   ├── models/             
│   │   ├── screens/            
│   │   └── services/           
│   └── pubspec.yaml
├── web-admin-backend/          
│   ├── src/
│   │   ├── controllers/        
│   │   ├── models/             
│   │   ├── routes/             
│   │   └── views/              
│   ├── .env                    
│   └── server.js               
└── README.md
```
