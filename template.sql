CREATE TABLE IF NOT EXISTS `vehicles_impound_data` (
  `vin` varchar(17) NOT NULL,
  `sum` int(10) unsigned NOT NULL DEFAULT 50,
  `reason` text DEFAULT NULL,
  KEY `vin_fk1` (`vin`),
  CONSTRAINT `vin_fk1` FOREIGN KEY (`vin`) REFERENCES `vehicles` (`vin`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `vehicle_impound_update` AFTER UPDATE ON `vehicles` FOR EACH ROW BEGIN
    IF NEW.stored = "impound" THEN
        IF EXISTS (SELECT 1 FROM vehicles_impound_data WHERE vin = NEW.vin) THEN
            UPDATE vehicles_impound_data
            SET SUM = 50, reason = NULL
            WHERE vin = NEW.vin;
        ELSE
            INSERT INTO vehicles_impound_data (vin, sum, reason)
            VALUES (NEW.vin, 50, NULL);
        END IF;
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;