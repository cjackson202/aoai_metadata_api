-- MySQL Workbench Forward Engineering  
  
-- Disable unique checks, foreign key checks, and set SQL mode for the session  
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;  
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;  
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';  
  
-- -------------------------------------------------------  
-- Schema aoai_api  
-- -------------------------------------------------------  
  
-- Create schema if it does not exist and set default character set and collation  
CREATE SCHEMA IF NOT EXISTS `aoai_api` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;  
-- Use the created schema  
USE `aoai_api`;  
  
-- -------------------------------------------------------  
-- Table aoai_api.aoaisystem  
-- -------------------------------------------------------  
  
-- Drop table if it exists to ensure a clean state  
DROP TABLE IF EXISTS `aoai_api`.`aoaisystem`;  
-- Create table aoaisystem  
CREATE TABLE IF NOT EXISTS `aoai_api`.`aoaisystem` (  
  `system_id` INT NOT NULL AUTO_INCREMENT,  
  `system_prompt` MEDIUMTEXT NULL DEFAULT NULL,  
  `system_proj` VARCHAR(100) NULL DEFAULT NULL,  
  `prompt_number` INT NULL DEFAULT NULL,  
  PRIMARY KEY (`system_id`)  
) ENGINE = InnoDB AUTO_INCREMENT = 92 DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;  
  
-- -------------------------------------------------------  
-- Table aoai_api.python_api  
-- -------------------------------------------------------  
  
-- Drop table if it exists to ensure a clean state  
DROP TABLE IF EXISTS `aoai_api`.`python_api`;  
-- Create table python_api  
CREATE TABLE IF NOT EXISTS `aoai_api`.`python_api` (  
  `api_id` INT NOT NULL AUTO_INCREMENT,  
  `api_name` VARCHAR(2048) NOT NULL,  
  PRIMARY KEY (`api_id`)  
) ENGINE = InnoDB AUTO_INCREMENT = 30 DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;  
  
-- -------------------------------------------------------  
-- Table aoai_api.models  
-- -------------------------------------------------------  
  
-- Drop table if it exists to ensure a clean state  
DROP TABLE IF EXISTS `aoai_api`.`models`;  
-- Create table models  
CREATE TABLE IF NOT EXISTS `aoai_api`.`models` (  
  `model_id` INT NOT NULL AUTO_INCREMENT,  
  `model` VARCHAR(255) NULL DEFAULT NULL,  
  `prompt_price` DECIMAL(10,6) NULL DEFAULT NULL,  
  `completion_price` DECIMAL(10,6) NULL DEFAULT NULL,  
  `tiktoken_encoding` VARCHAR(45) NULL DEFAULT NULL,  
  PRIMARY KEY (`model_id`)  
) ENGINE = InnoDB AUTO_INCREMENT = 13 DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;  
  
-- -------------------------------------------------------  
-- Table aoai_api.users  
-- -------------------------------------------------------  
  
-- Drop table if it exists to ensure a clean state  
DROP TABLE IF EXISTS `aoai_api`.`users`;  
-- Create table users  
CREATE TABLE IF NOT EXISTS `aoai_api`.`users` (  
  `entra_object_id` VARCHAR(36) NOT NULL,  
  `entra_principal_name` VARCHAR(255) NULL DEFAULT NULL,  
  PRIMARY KEY (`entra_object_id`)  
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;  
  
-- -------------------------------------------------------  
-- Table aoai_api.prompt  
-- -------------------------------------------------------  
  
-- Drop table if it exists to ensure a clean state  
DROP TABLE IF EXISTS `aoai_api`.`prompt`;  
-- Create table prompt  
CREATE TABLE IF NOT EXISTS `aoai_api`.`prompt` (  
  `prompt_id` INT NOT NULL AUTO_INCREMENT,  
  `system_id` INT NULL DEFAULT NULL,  
  `user_prompt` MEDIUMTEXT NULL DEFAULT NULL,  
  `tokens` INT NULL DEFAULT NULL,  
  `price` DECIMAL(10,5) NULL DEFAULT NULL,  
  `timestamp` VARCHAR(20) NULL DEFAULT NULL,  
  `entra_object_id` VARCHAR(36) NULL DEFAULT NULL,  
  PRIMARY KEY (`prompt_id`),  
  INDEX `system_id` (`system_id` ASC) VISIBLE,  
  INDEX `fk_user` (`entra_object_id` ASC) VISIBLE,  
  CONSTRAINT `fk_user`  
    FOREIGN KEY (`entra_object_id`)  
    REFERENCES `aoai_api`.`users` (`entra_object_id`)  
    ON DELETE CASCADE,  
  CONSTRAINT `prompt_ibfk_1`  
    FOREIGN KEY (`system_id`)  
    REFERENCES `aoai_api`.`aoaisystem` (`system_id`)  
) ENGINE = InnoDB AUTO_INCREMENT = 267 DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;  
  
-- -------------------------------------------------------  
-- Table aoai_api.chat_completions  
-- -------------------------------------------------------  
  
-- Drop table if it exists to ensure a clean state  
DROP TABLE IF EXISTS `aoai_api`.`chat_completions`;  
-- Create table chat_completions  
CREATE TABLE IF NOT EXISTS `aoai_api`.`chat_completions` (  
  `completion_id` INT NOT NULL AUTO_INCREMENT,  
  `model_id` INT NULL DEFAULT NULL,  
  `prompt_id` INT NULL DEFAULT NULL,  
  `api_id` INT NULL DEFAULT NULL,  
  `chat_completion` MEDIUMTEXT NULL DEFAULT NULL,  
  `tokens` INT NULL DEFAULT NULL,  
  `price` DECIMAL(10,5) NULL DEFAULT NULL,  
  `search_score` DECIMAL(10,7) NULL DEFAULT NULL,  
  `timestamp` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,  
  PRIMARY KEY (`completion_id`),  
  INDEX `model_id` (`model_id` ASC) VISIBLE,  
  INDEX `prompt_id` (`prompt_id` ASC) VISIBLE,  
  INDEX `api_id_idx` (`api_id` ASC) VISIBLE,  
  CONSTRAINT `api_id`  
    FOREIGN KEY (`api_id`)  
    REFERENCES `aoai_api`.`python_api` (`api_id`),  
  CONSTRAINT `chat_completions_ibfk_1`  
    FOREIGN KEY (`model_id`)  
    REFERENCES `aoai_api`.`models` (`model_id`),  
  CONSTRAINT `chat_completions_ibfk_2`  
    FOREIGN KEY (`prompt_id`)  
    REFERENCES `aoai_api`.`prompt` (`prompt_id`)  
) ENGINE = InnoDB AUTO_INCREMENT = 267 DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;  
  
-- -------------------------------------------------------  
-- Placeholder table for view aoai_api.aoai_cost_total  
-- -------------------------------------------------------  
  
-- Create placeholder table for view aoai_cost_total  
CREATE TABLE IF NOT EXISTS `aoai_api`.`aoai_cost_total` (`id` INT);  
  
-- -------------------------------------------------------  
-- Placeholder table for view aoai_api.aoai_metadata  
-- -------------------------------------------------------  
  
-- Create placeholder table for view aoai_metadata  
CREATE TABLE IF NOT EXISTS `aoai_api`.`aoai_metadata` (  
  `System prompt` INT,  
  `Prompt Number` INT,  
  `User prompt` INT,  
  `User prompt tokens` INT,  
  `Prompt price` INT,  
  `Time asked` INT,  
  `AI response` INT,  
  `AI response tokens` INT,  
  `Completion price` INT,  
  `Search score` INT,  
  `Time answered` INT,  
  `AI model` INT,  
  `AOAI MySQL API` INT  
);  
  
-- -------------------------------------------------------  
-- Placeholder table for view aoai_api.aoai_users_metadata  
-- -------------------------------------------------------  
  
-- Create placeholder table for view aoai_users_metadata  
CREATE TABLE IF NOT EXISTS `aoai_api`.`aoai_users_metadata` (  
  `System prompt` INT,  
  `Prompt Number` INT,  
  `Active User` INT,  
  `User prompt` INT,  
  `User prompt tokens` INT,  
  `Prompt price` INT,  
  `Time asked` INT,  
  `AI response` INT,  
  `AI response tokens` INT,  
  `Completion price` INT,  
  `Search score` INT,  
  `Time answered` INT,  
  `AI model` INT,  
  `AOAI MySQL API` INT  
);  
  
-- -------------------------------------------------------  
-- Procedure UpdateUserName  
-- -------------------------------------------------------  
  
-- Drop procedure if it exists to ensure a clean state  
USE `aoai_api`;  
DROP procedure IF EXISTS `aoai_api`.`UpdateUserName`;  
DELIMITER $$  
-- Create procedure UpdateUserName  
USE `aoai_api`$$  
CREATE DEFINER=`appdevaoai`@`%` PROCEDURE `UpdateUserName`(  
  IN p_new_name VARCHAR(255),  
  IN p_entra_object_id CHAR(36)  
)  
BEGIN  
  UPDATE users  
  SET entra_principal_name = p_new_name  
  WHERE entra_object_id = p_entra_object_id;  
END$$  
DELIMITER ;  
  
-- -------------------------------------------------------  
-- View aoai_api.aoai_cost_total  
-- -------------------------------------------------------  
  
-- Drop table and view if they exist to ensure a clean state  
DROP TABLE IF EXISTS `aoai_api`.`aoai_cost_total`;  
DROP VIEW IF EXISTS `aoai_api`.`aoai_cost_total`;  
USE `aoai_api`;  
-- Create view aoai_cost_total  
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`appdevaoai`@`%` SQL SECURITY DEFINER VIEW `aoai_api`.`aoai_cost_total` AS  
WITH `dailysums` AS (  
  SELECT   
    DATE_FORMAT(`aoai_api`.`prompt`.`timestamp`,'%Y-%m') AS `Month`,  
    DATE_FORMAT(`aoai_api`.`prompt`.`timestamp`,'%Y-%m-%d') AS `Day`,  
    SUM(`aoai_api`.`prompt`.`price`) AS `Sum total from prompt only ($)`,  
    SUM(`aoai_api`.`chat_completions`.`price`) AS `Sum total from prompt + ai response ($)`  
  FROM (`aoai_api`.`prompt`  
  JOIN `aoai_api`.`chat_completions` ON (`aoai_api`.`prompt`.`prompt_id` = `aoai_api`.`chat_completions`.`prompt_id`))  
  GROUP BY `Month`, `Day`  
)  
SELECT   
  `dailysums`.`Month` AS `Month`,  
  `dailysums`.`Day` AS `Day`,  
  `dailysums`.`Sum total from prompt only ($)` AS `Sum total from prompt only ($)`,  
  `dailysums`.`Sum total from prompt + ai response ($)` AS `Sum total from prompt + ai response ($)`,  
  SUM(`dailysums`.`Sum total from prompt only ($)`) OVER (ORDER BY `dailysums`.`Day`) AS `Cumulative Sum from prompt only ($)`,  
  SUM((`dailysums`.`Sum total from prompt only ($)` + `dailysums`.`Sum total from prompt + ai response ($)`)) OVER (ORDER BY `dailysums`.`Day`) AS `Cumulative Sum Total ($)`  
FROM `dailysums`  
ORDER BY `dailysums`.`Day`;  
  
-- -------------------------------------------------------  
-- View aoai_api.aoai_metadata  
-- -------------------------------------------------------  
  
-- Drop table and view if they exist to ensure a clean state  
DROP TABLE IF EXISTS `aoai_api`.`aoai_metadata`;  
DROP VIEW IF EXISTS `aoai_api`.`aoai_metadata`;  
USE `aoai_api`;  
-- Create view aoai_metadata  
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`appdevaoai`@`%` SQL SECURITY DEFINER VIEW `aoai_api`.`aoai_metadata` AS  
SELECT   
  `aoai_api`.`aoaisystem`.`system_proj` AS `System prompt`,  
  `aoai_api`.`aoaisystem`.`prompt_number` AS `Prompt Number`,  
  `aoai_api`.`prompt`.`user_prompt` AS `User prompt`,  
  `aoai_api`.`prompt`.`tokens` AS `User prompt tokens`,  
  `aoai_api`.`prompt`.`price` AS `Prompt price`,  
  `aoai_api`.`prompt`.`timestamp` AS `Time asked`,  
  `aoai_api`.`chat_completions`.`chat_completion` AS `AI response`,  
  `aoai_api`.`chat_completions`.`tokens` AS `AI response tokens`,  
  `aoai_api`.`chat_completions`.`price` AS `Completion price`,  
  `aoai_api`.`chat_completions`.`search_score` AS `Search score`,  
  `aoai_api`.`chat_completions`.`timestamp` AS `Time answered`,  
  `aoai_api`.`models`.`model` AS `AI model`,  
  `aoai_api`.`python_api`.`api_name` AS `AOAI MySQL API`  
FROM   
  ((((`aoai_api`.`aoaisystem`  
  JOIN `aoai_api`.`prompt` ON (`aoai_api`.`aoaisystem`.`system_id` = `aoai_api`.`prompt`.`system_id`))  
  JOIN `aoai_api`.`chat_completions` ON (`aoai_api`.`prompt`.`prompt_id` = `aoai_api`.`chat_completions`.`prompt_id`))  
  JOIN `aoai_api`.`python_api` ON (`aoai_api`.`chat_completions`.`api_id` = `aoai_api`.`python_api`.`api_id`))  
  JOIN `aoai_api`.`models` ON (`aoai_api`.`chat_completions`.`model_id` = `aoai_api`.`models`.`model_id`))  
ORDER BY `aoai_api`.`prompt`.`timestamp` DESC;  
  
-- -------------------------------------------------------  
-- View aoai_api.aoai_users_metadata  
-- -------------------------------------------------------  
  
-- Drop table and view if they exist to ensure a clean state  
DROP TABLE IF EXISTS `aoai_api`.`aoai_users_metadata`;  
DROP VIEW IF EXISTS `aoai_api`.`aoai_users_metadata`;  
USE `aoai_api`;  
-- Create view aoai_users_metadata  
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`appdevaoai`@`%` SQL SECURITY DEFINER VIEW `aoai_api`.`aoai_users_metadata` AS  
SELECT   
  `aoai_api`.`aoaisystem`.`system_proj` AS `System prompt`,  
  `aoai_api`.`aoaisystem`.`prompt_number` AS `Prompt Number`,  
  `aoai_api`.`users`.`entra_principal_name` AS `Active User`,  
  `aoai_api`.`prompt`.`user_prompt` AS `User prompt`,  
  `aoai_api`.`prompt`.`tokens` AS `User prompt tokens`,  
  `aoai_api`.`prompt`.`price` AS `Prompt price`,  
  `aoai_api`.`prompt`.`timestamp` AS `Time asked`,  
  `aoai_api`.`chat_completions`.`chat_completion` AS `AI response`,  
  `aoai_api`.`chat_completions`.`tokens` AS `AI response tokens`,  
  `aoai_api`.`chat_completions`.`price` AS `Completion price`,  
  `aoai_api`.`chat_completions`.`search_score` AS `Search score`,  
  `aoai_api`.`chat_completions`.`timestamp` AS `Time answered`,  
  `aoai_api`.`models`.`model` AS `AI model`,  
  `aoai_api`.`python_api`.`api_name` AS `AOAI MySQL API`  
FROM   
  (((((`aoai_api`.`aoaisystem`  
  JOIN `aoai_api`.`prompt` ON (`aoai_api`.`aoaisystem`.`system_id` = `aoai_api`.`prompt`.`system_id`))  
  JOIN `aoai_api`.`chat_completions` ON (`aoai_api`.`prompt`.`prompt_id` = `aoai_api`.`chat_completions`.`prompt_id`))  
  JOIN `aoai_api`.`python_api` ON (`aoai_api`.`chat_completions`.`api_id` = `aoai_api`.`python_api`.`api_id`))  
  JOIN `aoai_api`.`models` ON (`aoai_api`.`chat_completions`.`model_id` = `aoai_api`.`models`.`model_id`))  
  JOIN `aoai_api`.`users` ON (`aoai_api`.`prompt`.`entra_object_id` = `aoai_api`.`users`.`entra_object_id`))  
ORDER BY `aoai_api`.`prompt`.`timestamp` DESC;  
  
-- Restore original settings  
SET SQL_MODE=@OLD_SQL_MODE;  
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;  
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;  