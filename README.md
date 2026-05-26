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
![Firebase](https://img.shields.io/badge/Database-Firebase_Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![GCP](https://img.shields.io/badge/Cloud-GCP_Ubuntu_VM-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)

---

## ✨ Fitur Utama

Sistem ini dibagi menjadi dua platform utama yang melayani *role* pengguna yang berbeda:

### 📱 1. Aplikasi Mobile (User / Warga)
Aplikasi berbasis **Flutter** yang didesain untuk kemudahan warga dalam mengelola sampah mereka.
- **Request Penjemputan Real-time:** Warga dapat meminta penjemputan sampah dengan koordinat GPS/lokasi secara real-time.
- **Katalog Voucher & Klaim Poin:** Warga dapat menukarkan poin yang didapat dari menyetor sampah dengan kado/sembako secara langsung.
- **Cek Saldo Poin:** Pantau total poin hasil konversi setoran sampah anorganik.
- **Riwayat Transaksi:** Histori setoran sampah (poin masuk) dan penukaran voucher (poin keluar).
- **Notifikasi Live:** Notifikasi otomatis ketika status penjemputan berubah, poin didapat, atau kado voucher baru ditambahkan admin.

### 💻 2. Aplikasi Web Admin & Backend API (Admin / Pengepul)
Sistem berbasis **Express.js** untuk web frontend dan REST API backend.
- **Manajemen Kategori & Harga:** Mengatur harga beli & poin sampah anorganik per kilogram.
- **Penerimaan Request Penjemputan Warga:** Mengonfirmasi antrean penjemputan dari warga secara dinamis.
- **Master Data Voucher:** Mengelola katalog kado/voucher sembako serta kuota stoknya.
- **Pencatatan Transaksi Penukaran:** Validasi pencairan poin kado secara historis.
- **Sinkronisasi Otomatis:** Perubahan harga dan kado tersinkronisasi ke Firestore secara real-time.

---

## 🏗️ Arsitektur Sistem

Proyek ini menggunakan pendekatan **Polyglot Persistence** untuk mengoptimalkan performa sesuai kebutuhan data:

1. **MySQL (Relational Data)**
   - Menangani data transaksional yang membutuhkan integritas tinggi (ACID Compliance).
   - Menyimpan tabel: `users`, `harga_sampah`, `request_jemput`, `laporan_setoran`, `voucher_reward`, dan `transaksi_penukaran`.
2. **Firebase Firestore (NoSQL Document Data)**
   - Menangani data yang dinamis, tidak terstruktur ketat, dan membutuhkan sinkronisasi *real-time* dengan operasi I/O cepat.
   - Menyimpan *collections*: `request_jemput_realtime` (untuk status & koordinat lokasi), `voucher_reward_realtime` (sync real-time stok kado), `harga_sampah_realtime` (sync real-time harga), dan `notifikasi`.
3. **Google Cloud Platform (GCP)**
   - Keseluruhan *backend* dan *database* berjalan secara *native* di dalam 1 *instance* **Ubuntu VM**.

---

## 📁 Struktur Folder

```
bank-sampah-digital/
├── mobile-warga/               # Aplikasi Android/iOS Flutter Warga
│   ├── lib/
│   │   ├── config/             # Base URL & Konstanta nama collection
│   │   ├── models/             # Data Models (User, Voucher, Notification)
│   │   ├── providers/          # State Management (Auth, Pickup)
│   │   ├── screens/            # Halaman UI
│   │   ├── services/           # REST API Client & Firestore Service
│   │   └── widgets/            # Reusable UI components
│   └── pubspec.yaml
├── web-admin/                  # Web Dashboard & Backend API
│   ├── backend/                # Node.js Express Server
│   │   ├── config/             # Firebase Admin & SQL config (serviceAccountKey.json)
│   │   └── server.js           # Server API utama & Firebase Sync Handler
│   └── frontend/               # Dashboard HTML/CSS/JS (Tailwind CDN)
│       ├── index.html          # Halaman utama Admin
│       ├── request_jemput.html # Antrean request jemput warga
│       ├── transaksi_penukaran.html # Riwayat klaim kado warga
│       └── ...
├── bank_sampah_digital.sql     # Database Schema MySQL
└── README.md
```

---

## ⚙️ Petunjuk Instalasi (Step-by-Step)

### Prerequisites (Prasyarat)
* Node.js versi 16+
* Flutter SDK (Dart 3.0+)
* Database MySQL / MariaDB
* Akun Firebase (dengan Firestore dan Firebase Auth aktif)

---

### Langkah 1: Setup Database MySQL
1. Pastikan server MySQL Anda berjalan.
2. Buat database baru bernama `bank_sampah_digital` (atau nama lain):
   ```sql
   CREATE DATABASE bank_sampah_digital;
   ```
3. Import file `bank_sampah_digital.sql` ke database yang baru dibuat:
   ```bash
   mysql -u username -p bank_sampah_digital < bank_sampah_digital.sql
   ```

---

### Langkah 2: Setup Firebase & Service Account Key
1. Buka [Firebase Console](https://console.firebase.google.com/), buat proyek baru.
2. Aktifkan **Firebase Authentication** (Metode Sign-in: Email & Password) dan **Cloud Firestore**.
3. Download file kunci privat (service account) untuk Express.js backend:
   * Masuk ke **Project Settings** -> **Service Accounts**.
   * Klik tombol **Generate new private key** (Hasilkan kunci privat baru).
   * File JSON akan terunduh. Rename file tersebut menjadi **`serviceAccountKey.json`**.
   * Tempatkan file tersebut di direktori: `web-admin/backend/config/serviceAccountKey.json`.
4. Untuk aplikasi Flutter:
   * Daftarkan aplikasi Android/iOS Anda ke proyek Firebase atau gunakan alat cli `flutterfire configure`.
   * Tempatkan file **`google-services.json`** di folder `mobile-warga/android/app/`.

---

### Langkah 3: Konfigurasi & Menjalankan Backend
1. Masuk ke file `web-admin/backend/server.js` dan sesuaikan kredensial kolam koneksi MySQL (`db`) sesuai dengan database lokal/VM Anda:
   ```javascript
   const db = mysql.createPool({
       host: 'localhost',      // sesuaikan IP host
       user: 'root',           // sesuaikan DB user
       password: 'password',   // sesuaikan DB password
       database: 'bank_sampah_digital' // sesuaikan nama DB
   });
   ```
2. Jalankan instalasi dependensi backend dan jalankan server Express:
   ```bash
   cd web-admin/backend
   npm install
   npm run dev
   ```
   *Server backend akan mendengarkan di port 3000 (`http://localhost:3000`).*

---

### Langkah 4: Konfigurasi & Menjalankan Aplikasi Flutter (Warga)
1. Masuk ke file `mobile-warga/lib/config/app_constants.dart`.
2. Ganti nilai variabel `baseUrl` menggunakan IP host server Express backend Anda (atau `http://10.0.2.2:3000/api` untuk emulator Android):
   ```dart
   static const String baseUrl = 'http://IP_SERVER_BE:3000/api';
   ```
3. Unduh dependensi Flutter dan jalankan aplikasi ke emulator atau perangkat fisik Anda:
   ```bash
   cd mobile-warga
   flutter pub get
   flutter run
   ```

---

### Langkah 5: Mengakses Web Admin (Pengepul)
* Buka folder `web-admin/frontend/` dan jalankan file `index.html` menggunakan Server Lokal (misalnya dengan ekstensi Live Server di VS Code, atau http-server Python/Node), atau buka file langsung di browser Anda.
