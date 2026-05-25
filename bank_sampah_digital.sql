-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 24 Bulan Mei 2026 pada 20.10
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
-- Table structure for table `harga_sampah`
--

CREATE TABLE `harga_sampah` (
  `id` int(11) NOT NULL,
  `kategori` varchar(50) NOT NULL,
  `nama_sampah` varchar(100) NOT NULL,
  `harga_per_kg` int(11) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `poin_per_kg` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `harga_sampah`
--

INSERT INTO `harga_sampah` (`id`, `kategori`, `nama_sampah`, `harga_per_kg`, `updated_at`, `poin_per_kg`) VALUES
(3, 'Plastik', 'Botol Plastik PET', 3000, '2026-05-25 21:46:26', 300),
(4, 'Plastik', 'Gelas Plastik', 2500, '2026-05-25 21:46:26', 250),
(5, 'Plastik', 'Jerigen Plastik', 4000, '2026-05-25 21:46:26', 400),
(6, 'Kertas', 'Kardus Bekas', 2500, '2026-05-25 21:46:26', 250),
(7, 'Kertas', 'Kertas HVS', 1800, '2026-05-25 21:46:26', 180),
(8, 'Kertas', 'Koran Bekas', 2000, '2026-05-25 21:46:26', 200),
(9, 'Logam', 'Kaleng Minuman', 5000, '2026-05-25 21:46:26', 500),
(10, 'Logam', 'Besi Bekas', 4500, '2026-05-25 21:46:26', 450),
(11, 'Logam', 'Aluminium', 7000, '2026-05-25 21:46:26', 700),
(12, 'Elektronik', 'Kabel Bekas', 8000, '2026-05-25 21:46:26', 800),
(13, 'Elektronik', 'Charger Rusak', 6000, '2026-05-25 21:46:26', 600),
(14, 'Kaca', 'Botol Kaca', 1500, '2026-05-25 21:46:26', 150),
(15, 'Kaca', 'Pecahan Kaca', 1000, '2026-05-25 21:46:26', 100),
(16, 'Minyak', 'Minyak Jelantah', 6000, '2026-05-25 21:46:26', 600),
(17, 'Organik', 'Kompos Organik', 1200, '2026-05-25 21:46:26', 120);

-- --------------------------------------------------------

--
-- Table structure for table `laporan_setoran`
--

CREATE TABLE `laporan_setoran` (
  `id` int(11) NOT NULL,
  `nama_warga` varchar(100) NOT NULL,
  `id_sampah` int(11) NOT NULL,
  `berat_kg` decimal(5,2) NOT NULL,
  `total_harga` int(11) NOT NULL,
  `tanggal_setor` timestamp NOT NULL DEFAULT current_timestamp(),
  `id_warga` int(11) DEFAULT NULL,
  `id_request` int(11) DEFAULT NULL,
  `poin_didapat` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `laporan_setoran`
--

INSERT INTO `laporan_setoran` (`id`, `nama_warga`, `id_sampah`, `berat_kg`, `total_harga`, `tanggal_setor`, `id_warga`, `id_request`, `poin_didapat`) VALUES
(5, 'cece', 7, '0.60', 1080, '2026-05-13 17:00:00', NULL, NULL, NULL),
(6, 'cece', 4, '0.60', 1500, '2026-05-14 13:07:47', NULL, NULL, NULL),
(7, 'cece', 4, '0.50', 1250, '2026-05-13 17:00:00', NULL, NULL, NULL),
(8, 'cece', 4, '0.40', 1000, '2026-05-13 17:00:00', NULL, NULL, NULL),
(10, 'cece', 4, '0.40', 1000, '2026-05-13 17:00:00', NULL, NULL, NULL),
(11, 'cece', 4, '0.50', 1250, '2026-05-13 17:00:00', NULL, NULL, NULL),
(12, 'cece', 10, '1.00', 500, '2026-05-13 17:00:00', NULL, NULL, NULL),
(13, 'cece', 4, '2.20', 5500, '2026-05-13 17:00:00', NULL, NULL, NULL),
(14, 'cece', 17, '0.40', 480, '2026-05-14 17:00:00', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `request_jemput`
--

CREATE TABLE `request_jemput` (
  `id` int(11) NOT NULL,
  `nama_warga` varchar(100) DEFAULT NULL,
  `rt` varchar(10) DEFAULT NULL,
  `rw` varchar(10) DEFAULT NULL,
  `jenis_sampah` varchar(100) DEFAULT NULL,
  `estimasi_berat` decimal(10,2) DEFAULT NULL,
  `tanggal_jemput` date DEFAULT NULL,
  `catatan` text DEFAULT NULL,
  `status` enum('menunggu','diterima','proses_diantar','selesai','ditolak') DEFAULT 'menunggu',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `id_warga` int(11) DEFAULT NULL,
  `id_sampah` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `request_jemput`
--

INSERT INTO `request_jemput` (`id`, `nama_warga`, `rt`, `rw`, `jenis_sampah`, `estimasi_berat`, `tanggal_jemput`, `catatan`, `status`, `created_at`, `id_warga`, `id_sampah`) VALUES
(1, 'cece', '101', '02', 'Plastik', '2.20', '0000-00-00', 'Tolong pagi', 'selesai', '2026-05-15 09:17:15', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `transaksi_penukaran`
--

CREATE TABLE `transaksi_penukaran` (
  `id` int(11) NOT NULL,
  `nama_warga` varchar(100) NOT NULL,
  `jenis_penukaran` enum('Uang','Sembako') NOT NULL,
  `id_voucher` int(11) DEFAULT NULL,
  `poin_ditukar` int(11) NOT NULL,
  `tanggal_tukar` timestamp NOT NULL DEFAULT current_timestamp(),
  `id_warga` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','warga') DEFAULT 'warga',
  `rt` varchar(10) DEFAULT NULL,
  `rw` varchar(10) DEFAULT NULL,
  `jenis_kelamin` enum('Laki-laki','Perempuan') DEFAULT NULL,
  `saldo_poin` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `nama`, `email`, `password`, `role`, `rt`, `rw`, `jenis_kelamin`, `saldo_poin`, `created_at`) VALUES
(1, 'Admin', 'admin@gmail.com', 'admin123', 'admin', NULL, NULL, NULL, 0, '2026-05-12 08:27:55'),
(2, 'fare', 'fare@gmail.com', 'reroll12', 'warga', '04', '04', 'Laki-laki', 0, '2026-05-25 14:11:06'),
(3, 'ariel', 'ariel@gmail.com', 'reroll12', 'warga', '04', '04', 'Laki-laki', 0, '2026-05-25 20:37:22');

-- --------------------------------------------------------

--
-- Table structure for table `voucher_reward`
--

CREATE TABLE `voucher_reward` (
  `id` int(11) NOT NULL,
  `nama_voucher` varchar(100) NOT NULL,
  `min_poin` int(11) NOT NULL,
  `stok` int(11) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `voucher_reward`
--

INSERT INTO `voucher_reward` (`id`, `nama_voucher`, `min_poin`, `stok`, `updated_at`) VALUES
(1, 'Minyak Goreng 1 Liter', 1500, 50, '2026-05-19 14:29:11'),
(2, 'Beras Premium 1 Kg', 1200, 100, '2026-05-19 14:29:11'),
(3, 'Gula Pasir 1 Kg', 1400, 40, '2026-05-19 14:29:11'),
(4, 'Telur Ayam 1 Kg', 2000, 30, '2026-05-19 16:03:44');

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
  ADD KEY `id_sampah` (`id_sampah`),
  ADD KEY `fk_laporan_warga` (`id_warga`),
  ADD KEY `fk_laporan_request` (`id_request`);

--
-- Indexes for table `request_jemput`
--
ALTER TABLE `request_jemput`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_request_jemput_warga` (`id_warga`),
  ADD KEY `fk_request_jemput_sampah` (`id_sampah`);

--
-- Indexes for table `transaksi_penukaran`
--
ALTER TABLE `transaksi_penukaran`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_sembako` (`id_voucher`),
  ADD KEY `fk_transaksi_warga` (`id_warga`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `voucher_reward`
--
ALTER TABLE `voucher_reward`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `laporan_setoran`
--
ALTER TABLE `laporan_setoran`
  ADD CONSTRAINT `fk_laporan_request` FOREIGN KEY (`id_request`) REFERENCES `request_jemput` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_laporan_sampah` FOREIGN KEY (`id_sampah`) REFERENCES `harga_sampah` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_laporan_warga` FOREIGN KEY (`id_warga`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `request_jemput`
--
ALTER TABLE `request_jemput`
  ADD CONSTRAINT `fk_request_jemput_sampah` FOREIGN KEY (`id_sampah`) REFERENCES `harga_sampah` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_request_jemput_warga` FOREIGN KEY (`id_warga`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `transaksi_penukaran`
--
ALTER TABLE `transaksi_penukaran`
  ADD CONSTRAINT `fk_transaksi_voucher` FOREIGN KEY (`id_voucher`) REFERENCES `voucher_reward` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_transaksi_warga` FOREIGN KEY (`id_warga`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
