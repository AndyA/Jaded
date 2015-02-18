CREATE DATABASE /*!32312 IF NOT EXISTS*/ `jaded`;
USE `jaded`;
-- MySQL dump 10.15  Distrib 10.0.16-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: jaded
-- ------------------------------------------------------
-- Server version	10.0.16-MariaDB-1~wheezy

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `wind_grid`
--

DROP TABLE IF EXISTS `wind_grid`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wind_grid` (
  `ty` int(10) unsigned NOT NULL,
  `tx` int(10) unsigned NOT NULL,
  `zoom` int(3) NOT NULL,
  `datum` double NOT NULL,
  KEY `wind_grid_tx` (`tx`),
  KEY `wind_grid_ty` (`ty`),
  KEY `wind_grid_zoom` (`zoom`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wind_grid`
--

LOCK TABLES `wind_grid` WRITE;
/*!40000 ALTER TABLE `wind_grid` DISABLE KEYS */;
/*!40000 ALTER TABLE `wind_grid` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'jaded'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-02-18  0:47:55
