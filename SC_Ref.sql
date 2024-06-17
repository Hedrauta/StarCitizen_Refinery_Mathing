/*
 Navicat Premium Dump SQL

 Source Server         : DAC_Rocky9
 Source Server Type    : MariaDB
 Source Server Version : 100522 (10.5.22-MariaDB)
 Source Host           : 85.114.134.215:4408
 Source Schema         : SC_Ref

 Target Server Type    : MariaDB
 Target Server Version : 100522 (10.5.22-MariaDB)
 File Encoding         : 65001

 Date: 17/06/2024 19:57:49
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for combinations
-- ----------------------------
DROP TABLE IF EXISTS `combinations`;
CREATE TABLE `combinations`  (
  `DbI1` int(32) NULL DEFAULT NULL,
  `DbI2` int(32) NULL DEFAULT NULL,
  `DbI3` int(32) NULL DEFAULT NULL,
  `DbI4` int(32) NULL DEFAULT NULL,
  `DbI5` int(32) NULL DEFAULT NULL,
  `DbID` int(32) NOT NULL AUTO_INCREMENT,
  `SCU` int(32) NULL DEFAULT 0,
  PRIMARY KEY (`DbID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 628 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for refinery
-- ----------------------------
DROP TABLE IF EXISTS `refinery`;
CREATE TABLE `refinery`  (
  `DbID` int(11) NOT NULL AUTO_INCREMENT,
  `Quantanium` int(32) NULL DEFAULT 0,
  `Gold` int(32) NULL DEFAULT 0,
  `Bexalite` int(32) NULL DEFAULT 0,
  `Taranite` int(32) NULL DEFAULT 0,
  PRIMARY KEY (`DbID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for timestamps
-- ----------------------------
DROP TABLE IF EXISTS `timestamps`;
CREATE TABLE `timestamps`  (
  `last_combo` bigint(20) NULL DEFAULT NULL,
  `last_entry` bigint(20) NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- View structure for Maths
-- ----------------------------
DROP VIEW IF EXISTS `Maths`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `Maths` AS select `refinery`.`DbID` AS `DbID`,case when `refinery`.`Quantanium` = 0 then 0 else cast(ceiling((`refinery`.`Quantanium` + 0.1) / 100) as signed) end AS `Quantanium`,case when `refinery`.`Gold` = 0 then 0 else cast(ceiling((`refinery`.`Gold` + 0.1) / 100) as signed) end AS `Gold`,case when `refinery`.`Bexalite` = 0 then 0 else cast(ceiling((`refinery`.`Bexalite` + 0.1) / 100) as signed) end AS `Bexalite`,case when `refinery`.`Taranite` = 0 then 0 else cast(ceiling((`refinery`.`Taranite` + 0.1) / 100) as signed) end AS `Taranite` from `refinery`;

-- ----------------------------
-- View structure for SumSCU
-- ----------------------------
DROP VIEW IF EXISTS `SumSCU`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `SumSCU` AS select `Maths`.`DbID` AS `DbID`,`Maths`.`Bexalite` + `Maths`.`Gold` + `Maths`.`Quantanium` + `Maths`.`Taranite` AS `SumSCU` from `Maths`;

SET FOREIGN_KEY_CHECKS = 1;
