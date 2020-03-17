-- --------------------------------------------------------
-- Host:                         192.168.1.117
-- Server version:               5.7.22 - MySQL Community Server (GPL)
-- Server OS:                    Win64
-- HeidiSQL Version:             9.5.0.5196
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for procedure development_goup_router.goup_bulk_upload_sim_inventory_column_details
DROP PROCEDURE IF EXISTS `goup_bulk_upload_sim_inventory_column_details`;
DELIMITER //
CREATE  PROCEDURE `goup_bulk_upload_sim_inventory_column_details`()
COMMENT  'This Procedure Helps to get column details .'
BEGIN
 /*
  	-----------------------------------------------------------------------------------------------------------------------------------
  	Description	:  This Procedure Helps to get column details .
  	Created On	:  18/09/2018
  	Created By	:  Nimisha Mittal
  	----------------------------------------------------------------------------------------------------------------
	Inputs		:  
	Output		:	Msg	
		-----------------------------------------------------------------------------------------------------------------
	*/
	SELECT CONCAT( GROUP_CONCAT(column_name ORDER BY ordinal_position SEPARATOR',')) AS columns
	FROM information_schema.columns
	WHERE table_name = 'bulk_upload_sim_inventory' AND column_name!='id' AND column_name!='file_id'AND TABLE_SCHEMA='development_goup_router';
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
