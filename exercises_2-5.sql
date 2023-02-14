CREATE DATABASE MyFunkDB; 			-- Завдання 2: Создать базу данных с именем “MyFunkDB. 

DROP DATABASE IF EXISTS MyFunkDB;

USE MyFunkDB;

DROP TABLE IF EXISTS general;

CREATE TABLE general				-- Завдання 3: В данной базе данных создать 3 таблицы: В 1-й содержатся имена и номера телефонов сотрудников некоторой компании.
(
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(30) NOT NULL,
phone VARCHAR(22) NOT NULL UNIQUE
);

DROP TABLE IF EXISTS staff;

CREATE TABLE staff				-- Завдання 3: Во 2-й Ведомости об их зарплате, и должностях: главный директор, менеджер, рабочий.
(
person_id INT,
salary DOUBLE NOT NULL,
position VARCHAR(40) NOT NULL,
FOREIGN KEY(person_id) REFERENCES general(id)
ON UPDATE CASCADE
ON DELETE CASCADE
);

DROP TABLE IF EXISTS personal_data;

CREATE TABLE personal_data				-- Завдання 3: В 3-й семейном положении, дате рождения, где они проживают.
(
person_id INT,
status VARCHAR(10) NOT NULL,
birthday DATE NOT NULL,
address VARCHAR(40) NOT NULL,
FOREIGN KEY(person_id) REFERENCES general(id)
ON UPDATE CASCADE
ON DELETE CASCADE
);


DELIMITER $$

DROP PROCEDURE IF EXISTS Trans_proc; $$			-- Завдання 4: Выполните ряд записей вставки в виде транзакции в хранимой процедуре. Если такой сотрудник имеется откатите базу данных обратно. 

CREATE PROCEDURE Trans_proc (IN name VARCHAR(30), IN phone VARCHAR(22), IN salary DOUBLE, IN position VARCHAR(40), IN status VARCHAR(10), IN birthday DATE, IN address VARCHAR(40))
BEGIN
DECLARE id INT;
START TRANSACTION;
	INSERT INTO general
	(name, phone)
	VALUES
	(name, phone);
	SET id = @@IDENTITY;
        
	INSERT INTO staff
	(person_id, salary, position)
	VALUES
	(id, salary, position);
        
	INSERT INTO personal_data
	(person_id, status, birthday, address)
	VALUES
	(id, status, birthday, address);
        
		IF EXISTS (SELECT * FROM general WHERE name = name AND phone = phone AND id != id)
		THEN
			ROLLBACK;
		END IF;
        
	COMMIT;

END $$

CALL Trans_proc ('Vasya', '(099)225-65-14', 66000, 'CEO', 'free', '1989-02-03', 'Main str, 10, Kyiv, 01231, UA'); $$
CALL Trans_proc ('Petya', '(050)187-32-24', 16000, 'Manager', 'married', '1999-05-12', 'Left str. 13, Lviv 07242, UA'); $$
CALL Trans_proc ('Tosha', '(097)278-12-65', 16000, 'Manager', 'married', '2000-06-15', 'Right str. 22, Kharkiv, 12331, UA'); $$
CALL Trans_proc ('Moisha', '(063)876-87-23', 6000, 'Engineer', 'free', '1992-09-30', 'Middle str. 3, Dnipro 54234, UA'); $$
CALL Trans_proc ('Izya', '(067)002-44-77', 6000, 'Engineer', 'widow', '1998-12-01', 'Sea str. 66, Odesa 00234, UA'); $$

CALL Trans_proc ('Izya', '(067)002-44-77', 6000, 'Engineer', 'widow', '1998-12-01', 'Sea str. 66, Odesa 00234, UA'); $$		-- дубликат по имени и номеру

SELECT * FROM general; $$
SELECT * FROM staff; $$ 
SELECT * FROM personal_data; $$



DELIMITER $$

DROP TRIGGER IF EXISTS perfect_deletion; $$		-- Завдання 5: Создайте триггер, который будет удалять записи со 2-й и 3-й таблиц перед удалением записей из таблиц сотрудников (1-й таблицы), чтобы не нарушить целостность данных.

CREATE TRIGGER perfect_deletion
BEFORE DELETE ON general
FOR EACH ROW
BEGIN
	DELETE FROM personal_data WHERE person_id = OLD.id;
    DELETE FROM staff WHERE person_id = OLD.id;
END; $$

DELETE FROM general WHERE name = 'Izya'; $$

DELETE FROM general WHERE id = 3; $$

SELECT * FROM general; $$
SELECT * FROM staff; $$
SELECT * FROM personal_data; $$