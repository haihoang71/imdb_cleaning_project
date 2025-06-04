-- Checking for duplciate and null value

SELECT `title`, `director`, `release_year`, COUNT(*)
FROM `imdb_raw`
GROUP BY `title`, `director`, `release_year`
HAVING COUNT(*) > 1;

SELECT * FROM `imdb_raw`
WHERE COALESCE(`title`, `director`, `release_year`, `runtime`, `genre`, `rating`, `metascore`, `gross`) IS NULL;

-- Standardize Data format
-- Convert release_year to YEAR format, runtime to INT format, gross to int format and add an id column

UPDATE `imdb_raw` SET `release_year` = SUBSTR(`release_year`, -5, 4);
ALTER TABLE `imdb_raw` MODIFY COLUMN `release_year` YEAR;

UPDATE `imdb_raw` SET `runtime` = TRIM(TRAILING " min" FROM `runtime`);
ALTER TABLE `imdb_raw` MODIFY COLUMN `runtime` INT;

ALTER TABLE `imdb_raw` RENAME COLUMN `gross` TO `gross(M)`;
UPDATE `imdb_raw` SET `gross(M)` = TRIM(LEADING "$" FROM `gross(M)`);
UPDATE `imdb_raw` SET `gross(M)` = TRIM(TRAILING "M" FROM `gross(M)`);
ALTER TABLE `imdb_raw` MODIFY COLUMN `gross(M)` DECIMAL(6,2);

ALTER TABLE `imdb_raw` ADD `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY;

-- Add a new movie table without genre column

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
    PRIMARY KEY (`id`)
);
INSERT INTO `imdb_clean`(`title`, `director`, `release_year`, `runtime`, `rating`, `metascore`, `gross(M)`)
SELECT `title`, `director`, `release_year`, `runtime`, `rating`, `metascore`, `gross(M)` FROM `imdb_raw`;

-- Create genre_table and a movie_genre table

DROP TABLE IF EXISTS `genre_table`;
CREATE TABLE `genre_table` (
	`id` INT AUTO_INCREMENT,
    `genre` VARCHAR(255),
    PRIMARY KEY (`id`)
);

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
		
        SELECT COUNT(*) FROM `imdb_raw` INTO row_num;
        SET row_index = 1;
        
        WHILE row_index <= row_num DO    
            SET occurance = (SELECT LENGTH(`imdb_raw`.`genre`) - LENGTH(REPLACE(`imdb_raw`.`genre`, ',', '')) + 1
				FROM `imdb_raw`
				WHERE `id` = row_index);
         
			SET i = 1;
            WHILE i <= occurance DO
				SET splitted_value = TRIM((SELECT REPLACE(
					SUBSTRING(
						SUBSTRING_INDEX(`imdb_raw`.`genre`, ',', i),
                        LENGTH(SUBSTRING_INDEX(`imdb_raw`.`genre`, ',', i - 1))
						+ 1), ',', ''
					) FROM `imdb_raw` WHERE `id` = row_index
				));
                IF splitted_value NOT IN (SELECT `genre` FROM `genre_table`) THEN
					INSERT INTO `genre_table`(`genre`)
					VALUES (splitted_value);
				END IF;
                INSERT INTO `movie_genre`(`movie_id`, `genre_id`)
				VALUES ((SELECT `id` FROM `imdb_raw` WHERE `id` = row_index),
					(SELECT `id` FROM `genre_table` WHERE splitted_value = `genre_table`.`genre`));
				SET i = i + 1;

				END WHILE;
			SET row_index = row_index + 1;
		END WHILE;
	END; $$
DELIMITER ;
CALL `create_genre`;

-- Drop imdb_raw table

DROP TABLE `imdb_raw`;
SHOW TABLES;