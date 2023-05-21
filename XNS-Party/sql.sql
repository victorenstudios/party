-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.5.16-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping structure for table framework.xns_event
CREATE TABLE IF NOT EXISTS `xns_event` (
  `identifier` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `coords` longtext DEFAULT NULL,
  `status` longtext DEFAULT NULL,
  UNIQUE KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Dumping data for table framework.xns_event: ~0 rows (approximately)
DELETE FROM `xns_event`;
/*!40000 ALTER TABLE `xns_event` DISABLE KEYS */;
/*!40000 ALTER TABLE `xns_event` ENABLE KEYS */;

-- Dumping structure for table framework.xns_family
CREATE TABLE IF NOT EXISTS `xns_family` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8 NOT NULL DEFAULT '0',
  `bio` longtext DEFAULT 'ไม่มีสังเขป',
  `member` longtext DEFAULT NULL,
  `boss` longtext DEFAULT NULL,
  `request` longtext DEFAULT NULL,
  `avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `membercount` int(11) DEFAULT NULL,
  `maxmembercount` int(11) DEFAULT NULL,
  `exp` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Dumping data for table framework.xns_family: ~0 rows (approximately)
DELETE FROM `xns_family`;
/*!40000 ALTER TABLE `xns_family` DISABLE KEYS */;
/*!40000 ALTER TABLE `xns_family` ENABLE KEYS */;

-- Dumping structure for table framework.xns_family_cooldown
CREATE TABLE IF NOT EXISTS `xns_family_cooldown` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `date` varchar(50) DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Dumping data for table framework.xns_family_cooldown: ~0 rows (approximately)
DELETE FROM `xns_family_cooldown`;
/*!40000 ALTER TABLE `xns_family_cooldown` DISABLE KEYS */;
/*!40000 ALTER TABLE `xns_family_cooldown` ENABLE KEYS */;

-- Dumping structure for table framework.xns_family_members
CREATE TABLE IF NOT EXISTS `xns_family_members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `grage` varchar(20) DEFAULT 'Member',
  `name` varchar(50) CHARACTER SET utf8 NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`identifier`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Dumping data for table framework.xns_family_members: ~0 rows (approximately)
DELETE FROM `xns_family_members`;
/*!40000 ALTER TABLE `xns_family_members` DISABLE KEYS */;
/*!40000 ALTER TABLE `xns_family_members` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;

ALTER TABLE `users` ADD COLUMN
(
   `point` int(11) NOT NULL DEFAULT '0'
) 
