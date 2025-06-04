/*DROP TABLE copy_imdb_raw
CREATE TABLE copy_imdb_raw AS SELECT * FROM imdb_raw;
SHOW TABLES;*/
/*-- Standardize Data format

-- Convert release_year to YEAR format
UPDATE imdb.copy_imdb_raw SET release_year = SUBSTR(release_year, -5, 4);
UPDATE imdb.copy_imdb_raw SET release_year = CAST(release_year AS YEAR);
-- Convert runtime to INT format
UPDATE imdb.copy_imdb_raw SET runtime = TRIM(TRAILING " min" FROM runtime);
ALTER TABLE imdb.copy_imdb_raw MODIFY COLUMN runtime INT;
-- Convert gross to int format
ALTER TABLE imdb.copy_imdb_raw RENAME COLUMN gross TO `gross(M)`;
UPDATE imdb.copy_imdb_raw SET `gross(M)` = TRIM(LEADING "$" FROM `gross(M)`);
UPDATE imdb.copy_imdb_raw SET `gross(M)` = TRIM(TRAILING "M" FROM `gross(M)`);
ALTER TABLE imdb.copy_imdb_raw MODIFY COLUMN `gross(M)` DECIMAL(6,2);
-- Add a new movie table without genre column
-- Add genre table
-- Add movie_genre table
-- Drop imdb_raw table*/
-- Checking for duplciate
-- Checking for null values

DROP TABLE IF EXISTS `movie_genre`;
DROP TABLE IF EXISTS `genre_table`;
CREATE TABLE `genre_table` (
	`id` INT auto_increment,
    `genre` VARCHAR(255),
    primary key (`id`));
-- ALTER TABLE copy_imdb_raw ADD id int NOT NULL AUTO_INCREMENT primary key;
DROP TABLE IF EXISTS `imdb_clean`;
CREATE TABLE `imdb_clean` (
	`id` INT AUTO_INCREMENT,
    `title` VARCHAR(500) NOT NULL,
    `director` VARCHAR(255) NOT NULL,
    `release_year` YEAR NOT NULL,
    `runtime` INT NOT NULL,
    `rating` DECIMAL (2,1),
    `metascore` INT,
    `gross(M)` DECIMAL(6,2),
    PRIMARY KEY (`id`));
INSERT INTO `imdb_clean`(`title`, `director`, `release_year`, `runtime`, `rating`, `metascore`, `gross(M)`)
SELECT `title`, `director`, `release_year`, `runtime`, `rating`, `metascore`, `gross(M)` FROM copy_imdb_raw;
    
DROP TABLE IF EXISTS `movie_genre`;
CREATE TABLE `movie_genre` (
	`movie_id` INT,
    `genre_id` INT,
    FOREIGN KEY (`movie_id`) REFERENCES `imdb_clean`(`id`),
    FOREIGN KEY (`genre_id`) REFERENCES `genre_table`(`id`));
DELIMITER $$
DROP PROCEDURE IF EXISTS `create_genre` $$
CREATE PROCEDURE `create_genre`()
	BEGIN
		DECLARE occurance INT DEFAULT 0;
		DECLARE i INT DEFAULT 0;
		DECLARE splitted_value VARCHAR(255);
        DECLARE row_num INT DEFAULT 0;
        DECLARE row_index INT DEFAULT 0;
        
        DROP TABLE IF EXISTS `tem_genre_table`;
        CREATE TEMPORARY TABLE tem_genre_table (
			`id` INT AUTO_INCREMENT,
            `tem_genre` VARCHAR(255),
            primary key (`id`));
		
        SELECT COUNT(*) FROM copy_imdb_raw INTO row_num;
        SET row_index = 1;
        
        WHILE row_index <= row_num DO    
            SET occurance = (SELECT LENGTH(copy_imdb_raw.genre) - LENGTH(REPLACE(copy_imdb_raw.genre, ',', '')) + 1 FROM copy_imdb_raw WHERE id = row_index);
         
			SET i = 1;
            WHILE i <= occurance DO
				SET splitted_value = TRIM((SELECT REPLACE(
					SUBSTRING(
						SUBSTRING_INDEX(copy_imdb_raw.genre, ',', i),
                        LENGTH(SUBSTRING_INDEX(copy_imdb_raw.genre, ',', i - 1))
						+ 1), ',', ''
					) FROM copy_imdb_raw WHERE id = row_index
				));
				INSERT INTO tem_genre_table(tem_genre)
				VALUES (splitted_value);
				SET i = i + 1;

				END WHILE;
			SET row_index = row_index + 1;
		END WHILE;
        INSERT IGNORE INTO genre_table(genre)
        SELECT DISTINCT(tem_genre) FROM tem_genre_table ORDER BY tem_genre;
	END; $$
DELIMITER ;
CALL create_genre;
DELIMITER $$
DROP PROCEDURE IF EXISTS `create_movie_genre` $$
CREATE PROCEDURE `create_movie_genre`()
	BEGIN
		DECLARE occurance INT DEFAULT 0;
		DECLARE i INT DEFAULT 0;
		DECLARE splitted_value VARCHAR(255);
        DECLARE row_num INT DEFAULT 0;
        DECLARE row_index INT DEFAULT 0;
        
        SELECT COUNT(*) FROM copy_imdb_raw INTO row_num;
        SET row_index = 1;
        
        WHILE row_index <= row_num DO    
            SET occurance = (SELECT LENGTH(copy_imdb_raw.genre) - LENGTH(REPLACE(copy_imdb_raw.genre, ',', '')) + 1 FROM copy_imdb_raw WHERE id = row_index);
         
			SET i = 1;
            WHILE i <= occurance DO
				SET splitted_value = TRIM((SELECT REPLACE(
					SUBSTRING(
						SUBSTRING_INDEX(copy_imdb_raw.genre, ',', i),
                        LENGTH(SUBSTRING_INDEX(copy_imdb_raw.genre, ',', i - 1))
						+ 1), ',', ''
					) FROM copy_imdb_raw WHERE id = row_index
				));
				INSERT INTO movie_genre(movie_id, genre_id)
				VALUES ((SELECT id FROM copy_imdb_raw WHERE id = row_index), (SELECT id FROM genre_table WHERE splitted_value = genre_table.genre));
				SET i = i + 1;

				END WHILE;
			SET row_index = row_index + 1;
		END WHILE;
	END; $$
DELIMITER ;
CALL create_movie_genre;