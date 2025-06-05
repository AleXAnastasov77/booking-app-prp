-- --------------------------------------------------------
-- Host:                         192.168.179.200
-- Server version:               8.4.4 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.10.0.7000
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for booking_system
CREATE DATABASE IF NOT EXISTS `booking_system` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `booking_system`;

-- Dumping structure for table booking_system.accommodation
CREATE TABLE IF NOT EXISTS `accommodation` (
  `accommodation_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `units_available` int unsigned NOT NULL,
  `price_per_night` decimal(10,0) DEFAULT NULL,
  `status` enum('Available','Temporarily closed','Closed') DEFAULT NULL,
  `description` text,
  PRIMARY KEY (`accommodation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table booking_system.accommodation: ~2 rows (approximately)
INSERT INTO `accommodation` (`accommodation_id`, `name`, `location`, `units_available`, `price_per_night`, `status`, `description`) VALUES
	(1, 'Mountain Lodge', 'Aspen, CO', 2, 300, 'Temporarily closed', 'A luxurious mountain lodge perfect for winter sports enthusiasts.'),
	(2, 'Beachside Resort', 'Miami, FL', 8, 200, 'Available', 'A beautiful beachside resort with stunning views and excellent amenities.');

-- Dumping structure for table booking_system.admin_actions
CREATE TABLE IF NOT EXISTS `admin_actions` (
  `action_id` int NOT NULL AUTO_INCREMENT,
  `admin_user_id` int DEFAULT NULL,
  `target_user_id` int DEFAULT NULL,
  `booking_id` int DEFAULT NULL,
  `accommodation_id` int DEFAULT NULL,
  `reservation_id` int DEFAULT NULL,
  `payment_id` int DEFAULT NULL,
  `action_type` enum('Modify Booking','Modify Account','Modify Accommodation','Modify Reservation') DEFAULT NULL,
  `action_details` text,
  `action_timestamp` datetime DEFAULT NULL,
  PRIMARY KEY (`action_id`),
  KEY `admin_user_id` (`admin_user_id`),
  KEY `target_user_id` (`target_user_id`),
  KEY `booking_id` (`booking_id`),
  KEY `accommodation_id` (`accommodation_id`),
  KEY `reservation_id` (`reservation_id`),
  KEY `payment_id` (`payment_id`),
  CONSTRAINT `admin_actions_ibfk_1` FOREIGN KEY (`admin_user_id`) REFERENCES `user` (`user_id`),
  CONSTRAINT `admin_actions_ibfk_2` FOREIGN KEY (`target_user_id`) REFERENCES `user` (`user_id`),
  CONSTRAINT `admin_actions_ibfk_3` FOREIGN KEY (`booking_id`) REFERENCES `booking` (`booking_id`),
  CONSTRAINT `admin_actions_ibfk_4` FOREIGN KEY (`accommodation_id`) REFERENCES `accommodation` (`accommodation_id`),
  CONSTRAINT `admin_actions_ibfk_5` FOREIGN KEY (`reservation_id`) REFERENCES `restaurant_reservation` (`reservation_id`),
  CONSTRAINT `admin_actions_ibfk_6` FOREIGN KEY (`payment_id`) REFERENCES `payment` (`payment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table booking_system.admin_actions: ~2 rows (approximately)
INSERT INTO `admin_actions` (`action_id`, `admin_user_id`, `target_user_id`, `booking_id`, `accommodation_id`, `reservation_id`, `payment_id`, `action_type`, `action_details`, `action_timestamp`) VALUES
	(1, 2, 1, 1, 1, NULL, NULL, 'Modify Booking', 'Changed booking status to confirmed', '2025-04-08 09:00:00'),
	(2, 2, 2, 2, 2, NULL, NULL, 'Modify Reservation', 'Modified reservation status to pending', '2025-04-08 10:00:00');

-- Dumping structure for table booking_system.booking
CREATE TABLE IF NOT EXISTS `booking` (
  `booking_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `vehicle_id` int DEFAULT NULL,
  `accommodation_id` int NOT NULL,
  `booking_date` datetime NOT NULL,
  `check_in_date` datetime NOT NULL,
  `check_out_date` datetime NOT NULL,
  `status` enum('Confirmed','Cancelled','Pending') DEFAULT NULL,
  PRIMARY KEY (`booking_id`),
  KEY `user_id` (`user_id`),
  KEY `vehicle_id` (`vehicle_id`),
  KEY `accommodation_id` (`accommodation_id`),
  CONSTRAINT `booking_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
  CONSTRAINT `booking_ibfk_2` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicle` (`vehicle_id`),
  CONSTRAINT `booking_ibfk_3` FOREIGN KEY (`accommodation_id`) REFERENCES `accommodation` (`accommodation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table booking_system.booking: ~5 rows (approximately)
INSERT INTO `booking` (`booking_id`, `user_id`, `vehicle_id`, `accommodation_id`, `booking_date`, `check_in_date`, `check_out_date`, `status`) VALUES
	(1, 1, 1, 1, '2025-04-08 08:00:00', '2025-04-10 14:00:00', '2025-04-15 11:00:00', 'Confirmed'),
	(2, 2, 2, 1, '2025-04-08 09:30:00', '2025-04-12 15:00:00', '2025-04-14 10:00:00', 'Pending'),
	(3, 1, 1, 1, '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', NULL),
	(5, 1, NULL, 1, '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', NULL),
	(6, 1, NULL, 1, '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', NULL);

-- Dumping structure for table booking_system.parking_location
CREATE TABLE IF NOT EXISTS `parking_location` (
  `location_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `total_slots` int DEFAULT '0',
  `available_slots` int DEFAULT '0',
  PRIMARY KEY (`location_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table booking_system.parking_location: ~2 rows (approximately)
INSERT INTO `parking_location` (`location_id`, `name`, `address`, `total_slots`, `available_slots`) VALUES
	(3, 'Downtown Parking', '123 Main St, Miami, FL', 50, 50),
	(4, 'Airport Parking', '456 Airport Rd, Miami, FL', 100, 100);

-- Dumping structure for table booking_system.parking_reservation
CREATE TABLE IF NOT EXISTS `parking_reservation` (
  `reservation_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `location_id` int NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `status` enum('Confirmed','Cancelled','Pending') DEFAULT 'Pending',
  PRIMARY KEY (`reservation_id`),
  KEY `user_id` (`user_id`),
  KEY `location_id` (`location_id`),
  CONSTRAINT `parking_reservation_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
  CONSTRAINT `parking_reservation_ibfk_2` FOREIGN KEY (`location_id`) REFERENCES `parking_location` (`location_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table booking_system.parking_reservation: ~2 rows (approximately)
INSERT INTO `parking_reservation` (`reservation_id`, `user_id`, `location_id`, `start_time`, `end_time`, `status`) VALUES
	(3, 1, 1, '2025-04-08 10:00:00', '2025-04-10 14:00:00', 'Confirmed'),
	(4, 2, 2, '2025-04-12 15:00:00', '2025-04-14 12:00:00', 'Pending');

-- Dumping structure for table booking_system.payment
CREATE TABLE IF NOT EXISTS `payment` (
  `payment_id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `amount` decimal(10,0) NOT NULL,
  `payment_date` datetime NOT NULL,
  `payment_method` enum('Credit Card','Cash') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `status` enum('Paid','Pending','Failed') DEFAULT NULL,
  PRIMARY KEY (`payment_id`),
  KEY `booking_id` (`booking_id`),
  CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `booking` (`booking_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table booking_system.payment: ~2 rows (approximately)
INSERT INTO `payment` (`payment_id`, `booking_id`, `amount`, `payment_date`, `payment_method`, `status`) VALUES
	(1, 1, 1000, '2025-04-08 10:00:00', 'Credit Card', 'Paid'),
	(2, 2, 600, '2025-04-08 12:00:00', 'Cash', 'Pending');

-- Dumping structure for table booking_system.restaurant
CREATE TABLE IF NOT EXISTS `restaurant` (
  `restaurant_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table booking_system.restaurant: ~2 rows (approximately)
INSERT INTO `restaurant` (`restaurant_id`, `name`, `location`) VALUES
	(1, 'Sunset Grill', 'Miami, FL'),
	(2, 'Mountain Bistro', 'Aspen, CO');

-- Dumping structure for table booking_system.restaurant_reservation
CREATE TABLE IF NOT EXISTS `restaurant_reservation` (
  `reservation_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `restaurant_id` int NOT NULL,
  `reservation_date` datetime DEFAULT NULL,
  `status` enum('Confirmed','Cancelled','Pending') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  PRIMARY KEY (`reservation_id`),
  KEY `user_id` (`user_id`),
  KEY `restaurant_id` (`restaurant_id`),
  CONSTRAINT `restaurant_reservation_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
  CONSTRAINT `restaurant_reservation_ibfk_2` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurant` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table booking_system.restaurant_reservation: ~2 rows (approximately)
INSERT INTO `restaurant_reservation` (`reservation_id`, `user_id`, `restaurant_id`, `reservation_date`, `status`) VALUES
	(1, 1, 1, '2025-04-10 18:00:00', 'Confirmed'),
	(2, 2, 2, '2025-04-12 20:00:00', 'Pending');

-- Dumping structure for table booking_system.user
CREATE TABLE IF NOT EXISTS `user` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `phone_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `hashed_password` char(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `role` enum('customer','admin') NOT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table booking_system.user: ~2 rows (approximately)
INSERT INTO `user` (`user_id`, `name`, `phone_number`, `email`, `hashed_password`, `role`) VALUES
	(1, 'John Doe', '123-456-7890', 'john.doe@example.com', '$2y$10$U8vxsO9BfAp9G1V2r3d06gD8Wzp7EO5HqG72Tqlr5Hr5DYPBd/f1K', 'customer'),
	(2, 'Jane Smith', '987-654-3210', 'jane.smith@example.com', '$2y$10$U8vxsO9BfAp9G1V2r3d06gD8Wzp7EO5HqG72Tqlr5Hr5DYPBd/f1K', 'admin');

-- Dumping structure for table booking_system.vehicle
CREATE TABLE IF NOT EXISTS `vehicle` (
  `vehicle_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `licence_plate` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `registration_date` datetime DEFAULT NULL,
  PRIMARY KEY (`vehicle_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `vehicle_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table booking_system.vehicle: ~2 rows (approximately)
INSERT INTO `vehicle` (`vehicle_id`, `user_id`, `licence_plate`, `registration_date`) VALUES
	(1, 1, 'ABC123', '2023-01-01 10:00:00'),
	(2, 2, 'XYZ789', '2023-02-15 15:30:00');

-- Dumping structure for trigger booking_system.update_available_units_after_booking
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `update_available_units_after_booking` AFTER INSERT ON `booking` FOR EACH ROW BEGIN
    UPDATE `accommodation`
    SET `units_available` = `units_available` - 1
    WHERE `accommodation_id` = NEW.accommodation_id;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
