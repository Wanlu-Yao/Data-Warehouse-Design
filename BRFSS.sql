-- MySQL Workbench Forward Engineering
-- -----------------------------------------------------
-- New Schema BRFSS
CREATE SCHEMA `BRFSS`;
-- Use New Schema BRFSS
USE `BRFSS` ;
-- -----------------------------------------------------
-- Table `BRFSS`.`demographics`
CREATE TABLE IF NOT EXISTS `BRFSS`.`demographics` (
  `zip` INT NOT NULL,
  `city` VARCHAR(45) NULL,
  `county` VARCHAR(45) NULL,
  PRIMARY KEY (`zip`))
ENGINE = InnoDB;
-- -----------------------------------------------------
-- Table `BRFSS`.`survey_result`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `BRFSS`.`survey_result` (
  `survey_id` INT NOT NULL AUTO_INCREMENT,
  `question` VARCHAR(200) NULL,
  `response` CHAR(3) NULL,
  `break_out` VARCHAR(45) NULL,
  `break_out_category` VARCHAR(45) NULL,
  `sample_size` INT NULL,
  `value` DECIMAL(5,3) NULL DEFAULT NULL,
  `zip` INT NULL,
  PRIMARY KEY (`survey_id`))
ENGINE = InnoDB;
-- -----------------------------------------------------
-- Table `BRFSS`.`survey_demographics`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `BRFSS`.`survey_demographics` (
  `zip` INT NOT NULL,
  `city` VARCHAR(45) NULL,
  `county` VARCHAR(45) NULL,
  PRIMARY KEY (`zip`))
ENGINE = InnoDB;
-- -----------------------------------------------------
-- Insert Data Using Import Wizard
-- -----------------------------------------------------
-- Data Exploration
-- Unique Count of zip in Table demographics
SELECT  COUNT(DISTINCT(zip)) FROM demographics;
-- Unique Count of zip in Table survey_demographics
SELECT  COUNT(DISTINCT(zip)) FROM survey_demographics;
-- Relationship Between Demographics and survey_demographics
SELECT * FROM demographics d
INNER JOIN survey_demographics s
ON d.zip =s.zip;
-- Relationship Between Demographics and survey_result
SELECT * FROM survey_result sr
WHERE EXISTS (SELECT * FROM demographics d WHERE d.zip = sr.zip);

-- Add Foreign Key Constraints
ALTER TABLE `BRFSS`.`survey_result` 
ADD INDEX `FK_demographics_zip_idx` (`zip` ASC) VISIBLE;
ALTER TABLE `BRFSS`.`survey_result` 
ADD CONSTRAINT `FK_demographics_zip`
  FOREIGN KEY (`zip`)
  REFERENCES `BRFSS`.`survey_demographics` (`zip`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;
-- -----------------------------------------------------
-- Data Analysis
-- Age Group
SELECT * FROM survey_result
WHERE break_out_category = 'Age Group' AND break_out= '18-24';
-- Areas that Have Highest Number of Respondents for Adolescent Alcohol Abuse
WITH result AS (
SELECT break_out,
	   break_out_category, 
       sample_size,
       value,
       sd.zip,
       city,
       county,
       value/sample_size AS heavy_drinker_rate
FROM survey_result sr
JOIN survey_demographics sd
ON sr.zip = sd.zip
WHERE break_out_category = 'Age Group' AND break_out= '18-24'
) 
SELECT * FROM result 
ORDER BY heavy_drinker_rate DESC 
LIMIT 1
;
-- Areas that Have Lowest Number of Respondents for Adolescent Alcohol Abuse
WITH result AS (
SELECT break_out,
	   break_out_category, 
       sample_size,
       value,
       sd.zip,
       city,
       county,
       value/sample_size AS heavy_drinker_rate
FROM survey_result sr
JOIN survey_demographics sd
ON sr.zip = sd.zip
WHERE break_out_category = 'Age Group' AND break_out= '18-24'
) 
SELECT * FROM result 
ORDER BY heavy_drinker_rate ASC 
LIMIT 1
;
-- Heavy Adolescent Drinkers by County 
WITH result AS (
SELECT break_out,
	   break_out_category, 
       sample_size,
       value,
       sd.zip,
       city,
       county,
       value/sample_size AS heavy_drinker_rate
FROM survey_result sr
JOIN survey_demographics sd
ON sr.zip = sd.zip
WHERE break_out_category = 'Age Group' AND break_out= '18-24'
),
rank_result AS (
SELECT *, RANK() OVER(PARTITION BY county ORDER BY heavy_drinker_rate DESC) AS county_rank
FROM result
)
SELECT * FROM rank_result;
-- Heavy Adolescent Drinkers by City
WITH result AS (
SELECT break_out,
	   break_out_category, 
       sample_size,
       value,
       sd.zip,
       city,
       county,
       value/sample_size AS heavy_drinker_rate
FROM survey_result sr
JOIN survey_demographics sd
ON sr.zip = sd.zip
WHERE break_out_category = 'Age Group' AND break_out= '18-24'
),
rank_result AS (
SELECT *, RANK() OVER(PARTITION BY city ORDER BY heavy_drinker_rate DESC) AS city_rank
FROM result
)
SELECT * FROM rank_result;


