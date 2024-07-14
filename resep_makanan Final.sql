-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 14 Jul 2024 pada 15.29
-- Versi server: 10.4.28-MariaDB
-- Versi PHP: 8.1.17

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `resep_makanan`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `cari_resep_by_nama_dan_kategori` (IN `nama_resep` VARCHAR(255), IN `nama_kategori` VARCHAR(100))   BEGIN
    IF nama_resep = '' OR nama_kategori = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Parameter nama_resep dan nama_kategori harus diisi.';
    ELSEIF NOT EXISTS (SELECT 1 FROM kategori WHERE nama_kategori = nama_kategori) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Kategori tidak valid.';
    ELSE
        SELECT r.id, r.nama, r.deskripsi, r.waktu_memasak, r.tingkat_kesulitan, k.nama_kategori
        FROM resep r
        JOIN kategori k ON r.kategori_id = k.id
        WHERE r.nama LIKE CONCAT('%', nama_resep, '%')
        AND k.nama_kategori = nama_kategori;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `masakan_rekomendasi` ()   BEGIN
	DECLARE v_nama VARCHAR(255);
	DECLARE v_tingkat_kesulitan ENUM('Mudah', 'Sedang', 'Sulit');
	DECLARE v_rekomendasi VARCHAR(255);
    
	SELECT nama, tingkat_kesulitan FROM resep
	ORDER BY RAND() LIMIT 1
	INTO v_nama, v_tingkat_kesulitan;
	CASE v_tingkat_kesulitan
    	WHEN 'Mudah' THEN
        	SET v_rekomendasi = 'OK';
    	WHEN 'Sedang' THEN
        	SET v_rekomendasi = 'Ahli';
    	WHEN 'Sulit' THEN
        	SET v_rekomendasi = 'Master';
    	ELSE
        	SET v_rekomendasi = NULL;
	END CASE;
SELECT v_nama AS nama, v_tingkat_kesulitan AS tingkat_kesulitan, v_rekomendasi AS rekomendasi;
END$$

--
-- Fungsi
--
CREATE DEFINER=`root`@`localhost` FUNCTION `cari_resep_by_kesulitan_dan_waktu` (`tingkat_kesulitan` ENUM('Mudah','Sedang','Sulit'), `waktu_memasak_maks` INT) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    DECLARE daftar_resep TEXT;
    IF tingkat_kesulitan NOT IN ('Mudah', 'Sedang', 'Sulit') THEN
        RETURN 'Tingkat kesulitan tidak valid. Pilih Mudah, Sedang, atau Sulit!';
    ELSEIF waktu_memasak_maks <= 0 THEN
        RETURN 'Waktu memasak harus lebih dari 0 menit!';
    ELSE
        SELECT GROUP_CONCAT(nama SEPARATOR ', ') INTO daftar_resep
        FROM resep
        WHERE tingkat_kesulitan = tingkat_kesulitan
        AND waktu_memasak <= waktu_memasak_maks;
        IF daftar_resep IS NULL THEN
            RETURN 'Tidak ada resep yang sesuai dengan kriteria.';
        ELSE
            RETURN daftar_resep;
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `hitung_jumlah_resep` () RETURNS INT(11)  BEGIN
    DECLARE jumlah_resep INT;
    SELECT COUNT(*) INTO jumlah_resep
    FROM resep;
    RETURN jumlah_resep;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `bahan`
--

CREATE TABLE `bahan` (
  `id` int(11) NOT NULL,
  `nama_bahan` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `bahan`
--

INSERT INTO `bahan` (`id`, `nama_bahan`) VALUES
(1, 'Ayam'),
(2, 'Bawang Merah'),
(3, 'Bawang Putih'),
(4, 'Cabai Merah'),
(5, 'Gula'),
(6, 'Garam'),
(7, 'Minyak Goreng'),
(8, 'Tepung Terigu'),
(9, 'Telur'),
(10, 'Santan'),
(11, 'Daging Sapi'),
(12, 'Brokoli'),
(13, 'Wortel'),
(14, 'Kentang'),
(15, 'Susu'),
(16, 'Cokelat'),
(17, 'Stroberi'),
(18, 'Teh'),
(19, 'Kopi'),
(20, 'Air'),
(21, 'Pasta'),
(22, 'Keju Parmesan'),
(23, 'Krim'),
(24, 'Ragi'),
(25, 'Saus Tomat'),
(26, 'Mozzarella'),
(27, 'Basil'),
(28, 'Nori'),
(29, 'Cuka Beras'),
(30, 'Ikan Tuna'),
(31, 'Alpukat'),
(32, 'Kaldu Ayam'),
(33, 'Serai'),
(34, 'Daun Jeruk'),
(35, 'Asam Jawa'),
(36, 'Baking Powder'),
(37, 'Vanili'),
(38, 'Kecap Manis');

--
-- Trigger `bahan`
--
DELIMITER $$
CREATE TRIGGER `after_delete_bahan` AFTER DELETE ON `bahan` FOR EACH ROW BEGIN
    INSERT INTO log_bahan (operasi, tabel, keterangan)
    VALUES ('AFTER DELETE', 'bahan', CONCAT( OLD.nama_bahan));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_update_bahan` AFTER UPDATE ON `bahan` FOR EACH ROW BEGIN
    INSERT INTO log_bahan (operasi, tabel, keterangan)
    VALUES ('AFTER UPDATE', 'bahan', CONCAT( NEW.nama_bahan));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_delete_bahan` BEFORE DELETE ON `bahan` FOR EACH ROW BEGIN
    INSERT INTO log_bahan (operasi, tabel, keterangan )
    VALUES ('BEFORE DELETE', 'bahan', CONCAT('nama_bahan: ', OLD.nama_bahan));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_update_bahan` BEFORE UPDATE ON `bahan` FOR EACH ROW BEGIN
    INSERT INTO log_bahan (operasi, tabel, keterangan)
    VALUES ('BEFORE UPDATE', 'bahan', CONCAT('OLD: ', OLD.nama_bahan, ' NEW: ', NEW.nama_bahan));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `horizontal_view`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `horizontal_view` (
`id` int(11)
,`nama_bahan` varchar(255)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `inside_view_local_bahan`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `inside_view_local_bahan` (
`id` int(11)
,`nama_bahan` varchar(255)
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `kategori`
--

CREATE TABLE `kategori` (
  `id` int(11) NOT NULL,
  `nama_kategori` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `kategori`
--

INSERT INTO `kategori` (`id`, `nama_kategori`) VALUES
(1, 'Masakan Indonesia'),
(2, 'Masakan Barat'),
(3, 'Masakan Asia'),
(4, 'Kue dan Dessert'),
(5, 'Minuman');

-- --------------------------------------------------------

--
-- Struktur dari tabel `langkah`
--

CREATE TABLE `langkah` (
  `id` int(11) NOT NULL,
  `resep_id` int(11) DEFAULT NULL,
  `no_urut` int(11) DEFAULT NULL,
  `deskripsi_langkah` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `langkah`
--

INSERT INTO `langkah` (`id`, `resep_id`, `no_urut`, `deskripsi_langkah`) VALUES
(1, 1, 1, 'Panaskan minyak goreng.'),
(2, 1, 2, 'Tumis bawang merah, bawang putih, dan cabai hingga harum.'),
(3, 1, 3, 'Masukkan telur, orak-arik hingga matang.'),
(4, 1, 4, 'Masukkan nasi, aduk rata.'),
(5, 1, 5, 'Tambahkan garam, gula, dan kecap manis. Aduk hingga rata.'),
(6, 1, 6, 'Masak hingga nasi matang dan bumbu meresap.'),
(7, 2, 1, 'Haluskan bawang merah, bawang putih, cabai, jahe, lengkuas, kunyit, dan kemiri.'),
(8, 2, 2, 'Tumis bumbu halus hingga harum.'),
(9, 2, 3, 'Masukkan daging sapi, aduk rata.'),
(10, 2, 4, 'Tambahkan santan, serai, daun jeruk, dan asam kandis. Aduk rata.'),
(11, 2, 5, 'Masak dengan api kecil sambil terus diaduk hingga santan menyusut dan daging empuk.'),
(12, 2, 6, 'Tambahkan garam dan gula. Aduk rata dan masak hingga bumbu meresap dan mengental.'),
(13, 3, 1, 'Potong dadu daging ayam.'),
(14, 3, 2, 'Haluskan bawang merah, bawang putih, kemiri, ketumbar, dan garam.'),
(15, 3, 3, 'Campurkan bumbu halus dengan daging ayam, aduk rata. Diamkan selama 30 menit.'),
(16, 3, 4, 'Tusuk daging ayam pada tusuk sate.'),
(17, 3, 5, 'Bakar sate di atas bara api hingga matang.'),
(18, 3, 6, 'Sajikan sate dengan bumbu kacang.'),
(19, 4, 1, 'Rebus spaghetti hingga al dente.'),
(20, 4, 2, 'Campur telur, keju parmesan, dan krim hingga rata.'),
(21, 4, 3, 'Tumis bawang putih hingga harum.'),
(22, 4, 4, 'Campurkan spaghetti dengan saus telur dan keju.'),
(23, 4, 5, 'Tambahkan garam dan lada hitam secukupnya.'),
(24, 5, 1, 'Campurkan ragi, gula, dan air hangat. Diamkan hingga berbusa.'),
(25, 5, 2, 'Campurkan tepung terigu, garam, dan minyak zaitun. Tuang campuran ragi, uleni hingga kalis.'),
(26, 5, 3, 'Diamkan adonan selama 1 jam hingga mengembang.'),
(27, 5, 4, 'Gilas adonan, olesi dengan saus tomat, taburi keju mozzarella dan daun basil.'),
(28, 5, 5, 'Panggang dalam oven hingga matang.'),
(29, 6, 1, 'Masak nasi sushi sesuai petunjuk kemasan.'),
(30, 6, 2, 'Campurkan cuka beras, gula, dan garam. Aduk hingga larut.'),
(31, 6, 3, 'Campurkan nasi sushi dengan campuran cuka beras.'),
(32, 6, 4, 'Letakkan nori di atas sushi mat.'),
(33, 6, 5, 'Ratakan nasi sushi di atas nori.'),
(34, 6, 6, 'Letakkan irisan ikan tuna dan alpukat di tengah nasi.'),
(35, 6, 7, 'Gulung sushi dengan bantuan sushi mat.'),
(36, 6, 8, 'Potong sushi menjadi beberapa bagian.'),
(37, 7, 1, 'Rebus kaldu ayam, serai, daun jeruk, dan lengkuas hingga mendidih.'),
(38, 7, 2, 'Masukkan jamur, tomat, cabai, dan saus ikan. Masak hingga jamur layu.'),
(39, 7, 3, 'Tambahkan air jeruk nipis, gula, dan garam. Aduk rata.'),
(40, 7, 4, 'Sajikan selagi hangat.'),
(41, 8, 1, 'Lelehkan cokelat dan mentega.'),
(42, 8, 2, 'Kocok telur dan gula hingga mengembang.'),
(43, 8, 3, 'Campurkan cokelat leleh, telur, tepung terigu, baking powder, dan vanili. Aduk rata.'),
(44, 8, 4, 'Tuang adonan ke dalam loyang yang sudah diolesi mentega dan ditaburi tepung.'),
(45, 8, 5, 'Panggang dalam oven hingga matang.'),
(46, 9, 1, 'Seduh teh dengan air panas.'),
(47, 9, 2, 'Tambahkan gula sesuai selera.'),
(48, 9, 3, 'Aduk hingga gula larut.'),
(49, 9, 4, 'Sajikan dengan es batu.'),
(50, 10, 1, 'Seduh kopi dengan air panas.'),
(51, 10, 2, 'Tambahkan susu kental manis sesuai selera.'),
(52, 10, 3, 'Aduk hingga rata.'),
(53, 10, 4, 'Sajikan hangat atau dingin.');

-- --------------------------------------------------------

--
-- Struktur dari tabel `log_bahan`
--

CREATE TABLE `log_bahan` (
  `id_log` int(11) NOT NULL,
  `operasi` varchar(50) DEFAULT NULL,
  `tabel` varchar(50) DEFAULT NULL,
  `waktu` timestamp NOT NULL DEFAULT current_timestamp(),
  `keterangan` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `log_resep`
--

CREATE TABLE `log_resep` (
  `id_log` int(11) NOT NULL,
  `operasi` varchar(50) DEFAULT NULL,
  `tabel` varchar(50) DEFAULT NULL,
  `waktu` timestamp NOT NULL DEFAULT current_timestamp(),
  `keterangan` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `masakanku_user`
--

CREATE TABLE `masakanku_user` (
  `id` int(11) NOT NULL,
  `nama` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `masakanku_user`
--

INSERT INTO `masakanku_user` (`id`, `nama`, `email`, `password`) VALUES
(1, 'miftah', 'miftah@email.com', '8d804a5c53b69a7342c5c3c7ddc5364d'),
(2, 'jo', 'jo@email.com', '8d804a5c53b69a7342c5c3c7ddc5364d'),
(3, 'raka', 'raka@email.com', '8d804a5c53b69a7342c5c3c7ddc5364d');

-- --------------------------------------------------------

--
-- Struktur dari tabel `profil_user`
--

CREATE TABLE `profil_user` (
  `user_id` int(11) NOT NULL,
  `tanggal_lahir` date DEFAULT NULL,
  `jenis_kelamin` enum('Laki-laki','Perempuan') DEFAULT NULL,
  `alamat` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `profil_user`
--

INSERT INTO `profil_user` (`user_id`, `tanggal_lahir`, `jenis_kelamin`, `alamat`) VALUES
(1, '2004-01-15', 'Laki-laki', 'Jl. Hacker No. 06'),
(2, '2003-12-22', 'Laki-laki', 'Jl. Jangan No. 08'),
(3, '2003-07-10', 'Laki-laki', 'Jl. Mencuri No. 1945');

-- --------------------------------------------------------

--
-- Struktur dari tabel `resep`
--

CREATE TABLE `resep` (
  `id` int(11) NOT NULL,
  `nama` varchar(255) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `waktu_memasak` int(11) DEFAULT NULL,
  `tingkat_kesulitan` enum('Mudah','Sedang','Sulit') DEFAULT NULL,
  `kategori_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `resep`
--

INSERT INTO `resep` (`id`, `nama`, `deskripsi`, `waktu_memasak`, `tingkat_kesulitan`, `kategori_id`) VALUES
(1, 'Nasi Goreng', 'Nasi goreng khas Indonesia dengan bumbu rempah yang kaya.', 30, 'Mudah', 1),
(2, 'Rendang', 'Masakan daging sapi khas Padang dengan cita rasa pedas dan kaya rempah.', 180, 'Sulit', 1),
(3, 'Sate Ayam', 'Sate ayam Madura dengan bumbu kacang yang lezat.', 45, 'Sedang', 1),
(4, 'Spaghetti Carbonara', 'Pasta Italia dengan saus krim, telur, dan keju Parmesan.', 20, 'Mudah', 2),
(5, 'Pizza Margherita', 'Pizza klasik dengan saus tomat, mozzarella, dan basil.', 30, 'Sedang', 2),
(6, 'Sushi', 'Hidangan nasi Jepang yang dikombinasikan dengan ikan segar atau makanan laut lainnya.', 60, 'Sulit', 3),
(7, 'Tom Yam', 'Sup asam pedas khas Thailand dengan cita rasa segar dan rempah yang kuat.', 40, 'Sedang', 3),
(8, 'Brownies', 'Kue cokelat panggang yang padat dan lezat.', 50, 'Mudah', 4),
(9, 'Es Teh Manis', 'Minuman teh hitam yang diseduh dengan gula.', 10, 'Mudah', 5),
(10, 'Kopi Susu', 'Minuman kopi yang dicampur dengan susu kental manis.', 15, 'Mudah', 5);

--
-- Trigger `resep`
--
DELIMITER $$
CREATE TRIGGER `after_insert_resep` AFTER INSERT ON `resep` FOR EACH ROW BEGIN
    INSERT INTO log_resep (operasi, tabel, keterangan)
    VALUES ('AFTER INSERT', 'resep', CONCAT(NEW.nama, ', ', NEW.deskripsi, ', ', NEW.waktu_memasak, ', ', NEW.tingkat_kesulitan, ', ', NEW.kategori_id));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_resep` BEFORE INSERT ON `resep` FOR EACH ROW BEGIN
    INSERT INTO log_resep (operasi, tabel, keterangan)
    VALUES ( 'BEFORE INSERT',  'resep', CONCAT( NEW.nama,', kategori_id: ', NEW.kategori_id,', deskripsi: ', NEW.deskripsi, ', waktu_memasak: ', NEW.waktu_memasak,', tingkat_kesulitan: ', NEW.tingkat_kesulitan));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `resep_bahan`
--

CREATE TABLE `resep_bahan` (
  `resep_id` int(11) NOT NULL,
  `bahan_id` int(11) NOT NULL,
  `jumlah` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `resep_bahan`
--

INSERT INTO `resep_bahan` (`resep_id`, `bahan_id`, `jumlah`) VALUES
(1, 9, '1 butir'),
(1, 5, '1 sendok teh'),
(1, 6, '1/2 sendok teh'),
(1, 4, '2 buah'),
(1, 8, '2 piring'),
(1, 7, '2 sendok makan'),
(1, 3, '2 siung'),
(1, 1, '200 gram'),
(1, 2, '3 siung'),
(2, 11, '1 buah'),
(2, 14, '1 buah'),
(2, 6, '1 sendok makan'),
(2, 2, '10 siung'),
(2, 12, '3 cm'),
(2, 13, '3 cm'),
(2, 4, '5 buah'),
(2, 16, '50 gram'),
(2, 10, '500 gram'),
(2, 3, '6 siung'),
(2, 15, '65 ml'),
(3, 18, '1 sendok makan'),
(3, 6, '1 sendok teh'),
(3, 17, '100 gram'),
(3, 5, '2 sendok makan'),
(3, 1, '500 gram'),
(3, 7, 'secukupnya'),
(4, 20, '100 gram'),
(4, 21, '100 ml'),
(4, 19, '250 gram'),
(4, 9, '3 butir'),
(4, 6, 'secukupnya'),
(4, 22, 'secukupnya'),
(5, 7, '1 sendok makan'),
(5, 5, '1 sendok teh'),
(5, 6, '1/2 sendok teh'),
(5, 25, '10 lembar'),
(5, 23, '15 gram'),
(5, 24, '200 gram'),
(5, 8, '250 gram'),
(5, 26, 'secukupnya'),
(6, 31, '1 buah'),
(6, 28, '1 lembar'),
(6, 5, '1 sendok teh'),
(6, 6, '1/2 sendok teh'),
(6, 29, '1/2 sendok teh'),
(6, 30, '100 gram'),
(6, 27, '200 gram'),
(7, 37, '1 sendok makan'),
(7, 6, '1 sendok teh'),
(7, 4, '10 buah'),
(7, 35, '2 buah'),
(7, 38, '2 sendok makan'),
(7, 34, '3 batang'),
(7, 33, '5 lembar'),
(7, 1, 'ekor'),
(8, 6, '1/4 sendok teh'),
(8, 5, '150 gram'),
(8, 9, '2 butir'),
(8, 16, '200 gram'),
(8, 8, '50 gram'),
(8, 21, '50 ml'),
(9, 5, '2 sendok makan'),
(9, 18, '2 sendok makan'),
(9, 20, '200 ml'),
(10, 5, '1 sendok makan'),
(10, 20, '150 ml'),
(10, 19, '2 sendok makan'),
(10, 15, '50 ml');

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `vertical_view`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `vertical_view` (
`id` int(11)
,`nama_bahan` varchar(255)
);

-- --------------------------------------------------------

--
-- Struktur untuk view `horizontal_view`
--
DROP TABLE IF EXISTS `horizontal_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `horizontal_view`  AS SELECT `bahan`.`id` AS `id`, `bahan`.`nama_bahan` AS `nama_bahan` FROM `bahan` WHERE `bahan`.`id` = 1 ;

-- --------------------------------------------------------

--
-- Struktur untuk view `inside_view_local_bahan`
--
DROP TABLE IF EXISTS `inside_view_local_bahan`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `inside_view_local_bahan`  AS SELECT `bahan`.`id` AS `id`, `bahan`.`nama_bahan` AS `nama_bahan` FROM `bahan`WITH LOCAL CHECK OPTION  ;

-- --------------------------------------------------------

--
-- Struktur untuk view `vertical_view`
--
DROP TABLE IF EXISTS `vertical_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vertical_view`  AS SELECT `bahan`.`id` AS `id`, `bahan`.`nama_bahan` AS `nama_bahan` FROM `bahan` ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `bahan`
--
ALTER TABLE `bahan`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `kategori`
--
ALTER TABLE `kategori`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `langkah`
--
ALTER TABLE `langkah`
  ADD PRIMARY KEY (`id`),
  ADD KEY `i_langkah` (`id`,`no_urut`);

--
-- Indeks untuk tabel `log_bahan`
--
ALTER TABLE `log_bahan`
  ADD PRIMARY KEY (`id_log`);

--
-- Indeks untuk tabel `log_resep`
--
ALTER TABLE `log_resep`
  ADD PRIMARY KEY (`id_log`);

--
-- Indeks untuk tabel `masakanku_user`
--
ALTER TABLE `masakanku_user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indeks untuk tabel `profil_user`
--
ALTER TABLE `profil_user`
  ADD PRIMARY KEY (`user_id`);

--
-- Indeks untuk tabel `resep`
--
ALTER TABLE `resep`
  ADD PRIMARY KEY (`id`),
  ADD KEY `i_resep` (`nama`,`tingkat_kesulitan`),
  ADD KEY `resep_ibfk_1` (`kategori_id`);

--
-- Indeks untuk tabel `resep_bahan`
--
ALTER TABLE `resep_bahan`
  ADD PRIMARY KEY (`resep_id`,`bahan_id`),
  ADD KEY `resep_bahan_ibfk_2` (`bahan_id`),
  ADD KEY `i_resep_bahan` (`resep_id`,`jumlah`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `bahan`
--
ALTER TABLE `bahan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT untuk tabel `kategori`
--
ALTER TABLE `kategori`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `langkah`
--
ALTER TABLE `langkah`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- AUTO_INCREMENT untuk tabel `log_bahan`
--
ALTER TABLE `log_bahan`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `log_resep`
--
ALTER TABLE `log_resep`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `masakanku_user`
--
ALTER TABLE `masakanku_user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `resep`
--
ALTER TABLE `resep`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `langkah`
--
ALTER TABLE `langkah`
  ADD CONSTRAINT `langkah_ibfk_1` FOREIGN KEY (`resep_id`) REFERENCES `resep` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `profil_user`
--
ALTER TABLE `profil_user`
  ADD CONSTRAINT `profil_user_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `masakanku_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `resep`
--
ALTER TABLE `resep`
  ADD CONSTRAINT `resep_ibfk_1` FOREIGN KEY (`kategori_id`) REFERENCES `kategori` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `resep_bahan`
--
ALTER TABLE `resep_bahan`
  ADD CONSTRAINT `resep_bahan_ibfk_1` FOREIGN KEY (`resep_id`) REFERENCES `resep` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `resep_bahan_ibfk_2` FOREIGN KEY (`bahan_id`) REFERENCES `bahan` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
