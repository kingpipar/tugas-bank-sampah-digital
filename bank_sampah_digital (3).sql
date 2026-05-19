-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: May 19, 2026 at 11:10 AM
-- Server version: 8.0.30
-- PHP Version: 8.3.13

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
-- Table structure for table `harga_sampah`
--

CREATE TABLE `harga_sampah` (
  `id` int NOT NULL,
  `kategori` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `nama_sampah` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `harga_per_kg` int NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `harga_sampah`
--

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

-- --------------------------------------------------------

--
-- Table structure for table `laporan_setoran`
--

CREATE TABLE `laporan_setoran` (
  `id` int NOT NULL,
  `nama_warga` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `id_sampah` int NOT NULL,
  `berat_kg` decimal(5,2) NOT NULL,
  `total_harga` int NOT NULL,
  `tanggal_setor` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `laporan_setoran`
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
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `title` varchar(100) DEFAULT NULL,
  `message` text,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `request_jemput`
--

CREATE TABLE `request_jemput` (
  `id` int NOT NULL,
  `nama_warga` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `alamat` text COLLATE utf8mb4_general_ci,
  `jenis_sampah` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `estimasi_berat` decimal(10,2) DEFAULT NULL,
  `tanggal_jemput` date DEFAULT NULL,
  `catatan` text COLLATE utf8mb4_general_ci,
  `status` enum('Menunggu','Diproses','Selesai') COLLATE utf8mb4_general_ci DEFAULT 'Menunggu',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `user_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `request_jemput`
--

INSERT INTO `request_jemput` (`id`, `nama_warga`, `alamat`, `jenis_sampah`, `estimasi_berat`, `tanggal_jemput`, `catatan`, `status`, `created_at`, `user_id`) VALUES
(3, 'Warga Baru', 'Alamat pengguna', 'Campuran', 5.00, '2026-05-19', 'asda', 'Menunggu', '2026-05-19 11:08:29', 8);

-- --------------------------------------------------------

--
-- Table structure for table `saldo_poin`
--

CREATE TABLE `saldo_poin` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `total_poin` int DEFAULT '0',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `transaksi_penukaran`
--

CREATE TABLE `transaksi_penukaran` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `hadiah` varchar(100) DEFAULT NULL,
  `poin_ditukar` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `nama` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `role` enum('admin','warga') COLLATE utf8mb4_general_ci DEFAULT 'warga',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `firebase_uid` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `nama`, `email`, `password`, `role`, `created_at`, `firebase_uid`) VALUES
(1, 'Admin', 'admin@gmail.com', 'admin123', 'admin', '2026-05-12 08:27:55', NULL),
(2, 'Budi', 'test@test.com', NULL, 'warga', '2026-05-19 06:00:06', '123'),
(3, 'Warga Baru', 'testsatu@banksampah.com', NULL, 'warga', '2026-05-19 06:13:21', 'yvTHkW9HDrXEgOpfhNKAz75OeHn2'),
(4, 'Warga Baru', 'warga@banksampah.com', NULL, 'warga', '2026-05-19 08:49:55', 'kwZMsY82qIP4tgfhDppCaDqy6iM2'),
(5, 'Warga Baru', 'testdua@banksampah.com', NULL, 'warga', '2026-05-19 09:42:24', 'w5hCj8ILlmVKcYQxt20irPRERMv2'),
(6, 'Warga Baru', 'tes@sampah.com', NULL, 'warga', '2026-05-19 10:00:55', 'tVrNuTLtfQTpTK4kSaxIsTIlrZu1'),
(7, 'Warga Baru', 'tes1@sampah.com', NULL, 'warga', '2026-05-19 10:08:38', 'VkieUOvOGdO88xEqO7lYgW0w6kB2'),
(8, 'Warga Baru', 'tes2@sampah.com', 'tes123', 'warga', '2026-05-19 10:11:21', 'RAr64yrMF9NLEvCLx6BthvOi4Bq2'),
(9, 'Warga Baru', 'tes3@gmail.com', 'tes123', 'warga', '2026-05-19 10:16:13', 'jmHsUg10JfZWFHLxDf3qVL9AFoo1');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `harga_sampah`
--
ALTER TABLE `harga_sampah`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `laporan_setoran`
--
ALTER TABLE `laporan_setoran`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_sampah` (`id_sampah`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `request_jemput`
--
ALTER TABLE `request_jemput`
  ADD PRIMARY KEY (`id`),
  ADD KEY `request_jemput_ibfk_1` (`user_id`);

--
-- Indexes for table `saldo_poin`
--
ALTER TABLE `saldo_poin`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `transaksi_penukaran`
--
ALTER TABLE `transaksi_penukaran`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `harga_sampah`
--
ALTER TABLE `harga_sampah`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `laporan_setoran`
--
ALTER TABLE `laporan_setoran`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `request_jemput`
--
ALTER TABLE `request_jemput`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `saldo_poin`
--
ALTER TABLE `saldo_poin`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transaksi_penukaran`
--
ALTER TABLE `transaksi_penukaran`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `laporan_setoran`
--
ALTER TABLE `laporan_setoran`
  ADD CONSTRAINT `laporan_setoran_ibfk_1` FOREIGN KEY (`id_sampah`) REFERENCES `harga_sampah` (`id`);

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `request_jemput`
--
ALTER TABLE `request_jemput`
  ADD CONSTRAINT `request_jemput_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `saldo_poin`
--
ALTER TABLE `saldo_poin`
  ADD CONSTRAINT `saldo_poin_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `transaksi_penukaran`
--
ALTER TABLE `transaksi_penukaran`
  ADD CONSTRAINT `transaksi_penukaran_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
