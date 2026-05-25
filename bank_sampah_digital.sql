-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
<<<<<<< HEAD
-- Waktu pembuatan: 15 Bulan Mei 2026 pada 14.35
=======
-- Waktu pembuatan: 24 Bulan Mei 2026 pada 20.10
>>>>>>> a9baf93d7a70f7bddedcd9d796d8cd697971b829
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bank_sampah_digital`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `harga_sampah`
--

CREATE TABLE `harga_sampah` (
  `id` int(11) NOT NULL,
  `kategori` varchar(50) NOT NULL,
  `nama_sampah` varchar(100) NOT NULL,
  `harga_per_kg` int(11) NOT NULL,
<<<<<<< HEAD
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
=======
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `poin_per_kg` int(11) DEFAULT 0
>>>>>>> a9baf93d7a70f7bddedcd9d796d8cd697971b829
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `harga_sampah`
--

<<<<<<< HEAD
INSERT INTO `harga_sampah` (`id`, `kategori`, `nama_sampah`, `harga_per_kg`, `updated_at`) VALUES
(1, 'Plastik', 'Botol Plastik PET', 3000, '2026-05-12 07:34:15'),
(2, 'Kertas', 'kardus bekas', 2500, '2026-05-12 07:49:46'),
(3, 'Plastik', 'Botol Plastik PET', 3000, '2026-05-12 10:07:48'),
(4, 'Plastik', 'Gelas Plastik', 2500, '2026-05-12 10:07:48'),
(5, 'Plastik', 'Jerigen Plastik', 4000, '2026-05-12 10:07:48'),
(6, 'Kertas', 'Kardus Bekas', 2500, '2026-05-12 10:07:48'),
(7, 'Kertas', 'Kertas HVS', 1800, '2026-05-12 10:07:48'),
(8, 'Kertas', 'Koran Bekas', 2000, '2026-05-12 10:07:48'),
(9, 'Logam', 'Kaleng Minuman', 5000, '2026-05-12 10:07:48'),
(10, 'Logam', 'Besi Bekas', 4500, '2026-05-12 10:07:48'),
(11, 'Logam', 'Aluminium', 7000, '2026-05-12 10:07:48'),
(12, 'Elektronik', 'Kabel Bekas', 8000, '2026-05-12 10:07:48'),
(13, 'Elektronik', 'Charger Rusak', 6000, '2026-05-12 10:07:48'),
(14, 'Kaca', 'Botol Kaca', 1500, '2026-05-12 10:07:48'),
(15, 'Kaca', 'Pecahan Kaca', 1000, '2026-05-12 10:07:48'),
(16, 'Minyak', 'Minyak Jelantah', 6000, '2026-05-12 10:07:48'),
(17, 'Organik', 'Kompos Organik', 1200, '2026-05-12 10:07:48');
=======
INSERT INTO `harga_sampah` (`id`, `kategori`, `nama_sampah`, `harga_per_kg`, `updated_at`, `poin_per_kg`) VALUES
(1, 'Plastik', 'Botol Plastik PET', 3000, '2026-05-24 12:07:17', 19),
(2, 'Kertas', 'kardus bekas', 2500, '2026-05-24 12:07:17', 16),
(3, 'Plastik', 'Botol Plastik PET', 3000, '2026-05-24 12:07:17', 19),
(4, 'Plastik', 'Gelas Plastik', 2500, '2026-05-24 12:07:17', 16),
(5, 'Plastik', 'Jerigen Plastik', 4000, '2026-05-24 12:07:17', 25),
(6, 'Kertas', 'Kardus Bekas', 2500, '2026-05-24 12:07:17', 16),
(7, 'Kertas', 'Kertas HVS', 1800, '2026-05-24 12:07:17', 11),
(8, 'Kertas', 'Koran Bekas', 2000, '2026-05-24 12:07:17', 13),
(9, 'Logam', 'Kaleng Minuman', 5000, '2026-05-24 12:07:17', 31),
(10, 'Logam', 'Besi Bekas', 4500, '2026-05-24 12:07:17', 28),
(11, 'Logam', 'Aluminium', 7000, '2026-05-24 12:07:17', 44),
(12, 'Elektronik', 'Kabel Bekas', 8000, '2026-05-24 12:07:17', 50),
(13, 'Elektronik', 'Charger Rusak', 6000, '2026-05-24 12:07:17', 38),
(14, 'Kaca', 'Botol Kaca', 1500, '2026-05-24 12:07:17', 9),
(15, 'Kaca', 'Pecahan Kaca', 1000, '2026-05-24 12:07:17', 6),
(16, 'Minyak', 'Minyak Jelantah', 6000, '2026-05-24 12:07:17', 38),
(17, 'Organik', 'Kompos Organik', 1200, '2026-05-24 12:07:17', 8);
>>>>>>> a9baf93d7a70f7bddedcd9d796d8cd697971b829

-- --------------------------------------------------------

--
-- Struktur dari tabel `laporan_setoran`
--

CREATE TABLE `laporan_setoran` (
  `id` int(11) NOT NULL,
  `nama_warga` varchar(100) NOT NULL,
  `id_sampah` int(11) NOT NULL,
  `berat_kg` decimal(5,2) NOT NULL,
  `total_harga` int(11) NOT NULL,
  `tanggal_setor` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `laporan_setoran`
--

INSERT INTO `laporan_setoran` (`id`, `nama_warga`, `id_sampah`, `berat_kg`, `total_harga`, `tanggal_setor`) VALUES
(1, 'Budi Santoso', 1, 2.50, 7500, '2026-05-12 07:37:31'),
(2, 'ruye', 1, 5.00, 15000, '2026-05-12 07:47:57'),
(3, 'nomi', 2, 6.00, 15000, '2026-05-12 07:49:59'),
(4, 'ichang', 2, 999.99, 2147483647, '2026-05-12 10:04:01'),
(5, 'cece', 7, 0.60, 1080, '2026-05-13 17:00:00'),
(6, 'cece', 4, 0.60, 1500, '2026-05-14 13:07:47'),
(7, 'cece', 4, 0.50, 1250, '2026-05-13 17:00:00'),
(8, 'cece', 4, 0.40, 1000, '2026-05-13 17:00:00'),
(9, 'cece', 1, 0.50, 750, '2026-05-13 17:00:00'),
(10, 'cece', 4, 0.40, 1000, '2026-05-13 17:00:00'),
(11, 'cece', 4, 0.50, 1250, '2026-05-13 17:00:00'),
(12, 'cece', 10, 1.00, 500, '2026-05-13 17:00:00'),
(13, 'cece', 4, 2.20, 5500, '2026-05-13 17:00:00'),
(14, 'cece', 17, 0.40, 480, '2026-05-14 17:00:00');

-- --------------------------------------------------------

--
-- Struktur dari tabel `request_jemput`
--

CREATE TABLE `request_jemput` (
  `id` int(11) NOT NULL,
  `nama_warga` varchar(100) DEFAULT NULL,
  `alamat` text DEFAULT NULL,
  `jenis_sampah` varchar(100) DEFAULT NULL,
  `estimasi_berat` decimal(10,2) DEFAULT NULL,
  `tanggal_jemput` date DEFAULT NULL,
  `catatan` text DEFAULT NULL,
  `status` enum('Menunggu','Diproses','Selesai') DEFAULT 'Menunggu',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `request_jemput`
--

INSERT INTO `request_jemput` (`id`, `nama_warga`, `alamat`, `jenis_sampah`, `estimasi_berat`, `tanggal_jemput`, `catatan`, `status`, `created_at`) VALUES
(1, 'cece', 'Sleman', 'Plastik', 2.20, '0000-00-00', 'Tolong pagi', 'Menunggu', '2026-05-15 09:17:15');

-- --------------------------------------------------------

--
<<<<<<< HEAD
=======
-- Struktur dari tabel `transaksi_penukaran`
--

CREATE TABLE `transaksi_penukaran` (
  `id` int(11) NOT NULL,
  `nama_warga` varchar(100) NOT NULL,
  `jenis_penukaran` enum('Uang','Sembako') NOT NULL,
  `id_voucher` int(11) DEFAULT NULL,
  `poin_ditukar` int(11) NOT NULL,
  `tanggal_tukar` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
>>>>>>> a9baf93d7a70f7bddedcd9d796d8cd697971b829
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `role` enum('admin') DEFAULT 'admin',
<<<<<<< HEAD
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
=======
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `saldo_poin` int(11) DEFAULT 0
>>>>>>> a9baf93d7a70f7bddedcd9d796d8cd697971b829
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `users`
--

<<<<<<< HEAD
INSERT INTO `users` (`id`, `nama`, `email`, `password`, `role`, `created_at`) VALUES
(1, 'Admin', 'admin@gmail.com', 'admin123', 'admin', '2026-05-12 08:27:55');
=======
INSERT INTO `users` (`id`, `nama`, `email`, `password`, `role`, `created_at`, `saldo_poin`) VALUES
(1, 'Admin', 'admin@gmail.com', 'admin123', 'admin', '2026-05-12 08:27:55', 0);

-- --------------------------------------------------------

--
-- Struktur dari tabel `voucher_reward`
--

CREATE TABLE `voucher_reward` (
  `id` int(11) NOT NULL,
  `nama_voucher` varchar(100) NOT NULL,
  `min_poin` int(11) NOT NULL,
  `stok` int(11) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `voucher_reward`
--

INSERT INTO `voucher_reward` (`id`, `nama_voucher`, `min_poin`, `stok`, `updated_at`) VALUES
(1, 'Minyak Goreng 1 Liter', 1500, 50, '2026-05-19 14:29:11'),
(2, 'Beras Premium 1 Kg', 1200, 100, '2026-05-19 14:29:11'),
(3, 'Gula Pasir 1 Kg', 1400, 40, '2026-05-19 14:29:11'),
(4, 'Telur Ayam 1 Kg', 2000, 30, '2026-05-19 16:03:44');

-- --------------------------------------------------------

--
-- Struktur dari tabel `warga_rt1`
--

CREATE TABLE `warga_rt1` (
  `id` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `alamat` varchar(200) NOT NULL,
  `jenis_kelamin` enum('Laki-laki','Perempuan') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `warga_rt1`
--

INSERT INTO `warga_rt1` (`id`, `nama`, `alamat`, `jenis_kelamin`, `created_at`) VALUES
(1, 'Budi Santoso', 'RT 01/RW 02 No. 5, Temanggung', 'Laki-laki', '2026-05-24 16:37:47'),
(2, 'Siti Rahayu', 'RT 01/RW 02 No. 8, Temanggung', 'Perempuan', '2026-05-24 16:37:47'),
(3, 'Ahmad Fauzi', 'RT 01/RW 01 No. 12, Temanggung', 'Laki-laki', '2026-05-24 16:37:47'),
(4, 'Dewi Lestari', 'RT 01/RW 03 No. 3, Temanggung', 'Perempuan', '2026-05-24 16:37:47'),
(5, 'Hendra Wijaya', 'RT 01/RW 01 No. 7, Temanggung', 'Laki-laki', '2026-05-24 16:37:47'),
(6, 'Nur Hidayah', 'RT 01/RW 02 No. 15, Temanggung', 'Perempuan', '2026-05-24 16:37:47'),
(7, 'Rudi Hartono', 'RT 01/RW 04 No. 2, Temanggung', 'Laki-laki', '2026-05-24 16:37:47'),
(8, 'Rina Susanti', 'RT 01/RW 01 No. 9, Temanggung', 'Perempuan', '2026-05-24 16:37:47');
>>>>>>> a9baf93d7a70f7bddedcd9d796d8cd697971b829

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `harga_sampah`
--
ALTER TABLE `harga_sampah`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `laporan_setoran`
--
ALTER TABLE `laporan_setoran`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_sampah` (`id_sampah`);

--
-- Indeks untuk tabel `request_jemput`
--
ALTER TABLE `request_jemput`
  ADD PRIMARY KEY (`id`);

--
<<<<<<< HEAD
=======
-- Indeks untuk tabel `transaksi_penukaran`
--
ALTER TABLE `transaksi_penukaran`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_sembako` (`id_voucher`);

--
>>>>>>> a9baf93d7a70f7bddedcd9d796d8cd697971b829
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
<<<<<<< HEAD
=======
-- Indeks untuk tabel `voucher_reward`
--
ALTER TABLE `voucher_reward`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `warga_rt1`
--
ALTER TABLE `warga_rt1`
  ADD PRIMARY KEY (`id`);

--
>>>>>>> a9baf93d7a70f7bddedcd9d796d8cd697971b829
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `harga_sampah`
--
ALTER TABLE `harga_sampah`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT untuk tabel `laporan_setoran`
--
ALTER TABLE `laporan_setoran`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT untuk tabel `request_jemput`
--
ALTER TABLE `request_jemput`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
<<<<<<< HEAD
=======
-- AUTO_INCREMENT untuk tabel `transaksi_penukaran`
--
ALTER TABLE `transaksi_penukaran`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
>>>>>>> a9baf93d7a70f7bddedcd9d796d8cd697971b829
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
<<<<<<< HEAD
=======
-- AUTO_INCREMENT untuk tabel `voucher_reward`
--
ALTER TABLE `voucher_reward`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `warga_rt1`
--
ALTER TABLE `warga_rt1`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
>>>>>>> a9baf93d7a70f7bddedcd9d796d8cd697971b829
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `laporan_setoran`
--
ALTER TABLE `laporan_setoran`
  ADD CONSTRAINT `laporan_setoran_ibfk_1` FOREIGN KEY (`id_sampah`) REFERENCES `harga_sampah` (`id`);

<<<<<<< HEAD
-- --------------------------------------------------------

--
-- Struktur dari tabel `transaksi_penukaran`
--

CREATE TABLE `transaksi_penukaran` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nama_warga` varchar(100) NOT NULL,
  `jenis_penukaran` enum('Uang','Sembako') NOT NULL,
  `jumlah_poin` int(11) NOT NULL,
  `nilai_tukar` int(11) NOT NULL,
  `keterangan` text DEFAULT NULL,
  `status` enum('Pending','Diproses','Selesai','Ditolak') DEFAULT 'Pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `transaksi_penukaran`
--

INSERT INTO `transaksi_penukaran` (`nama_warga`, `jenis_penukaran`, `jumlah_poin`, `nilai_tukar`, `keterangan`, `status`) VALUES
('Budi Santoso', 'Uang', 15000, 15000, 'Tukar poin ke uang tunai', 'Selesai'),
('cece', 'Sembako', 10000, 10000, 'Tukar poin ke beras 5kg', 'Diproses');

=======
--
-- Ketidakleluasaan untuk tabel `transaksi_penukaran`
--
ALTER TABLE `transaksi_penukaran`
  ADD CONSTRAINT `fk_transaksi_voucher` FOREIGN KEY (`id_voucher`) REFERENCES `voucher_reward` (`id`) ON DELETE SET NULL;
>>>>>>> a9baf93d7a70f7bddedcd9d796d8cd697971b829
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
