CREATE DATABASE IF NOT EXISTS class;
USE class;
CREATE TABLE teacher(
id int NOT NULL AUTO_INCREMENT,
username VARCHAR(30) NOT NULL,
password VARCHAR(30) NOT NULL);
CREATE TABLE student(
id int NOT NULL AUTO_INCREMENT,
username VARCHAR(30) NOT NULL,
password VARCHAR(30) NOT NULL,
fullname VARCHAR(30) NOT NULL,
email VARCHAR(30) NOT NULL,
phonenum VARCHAR(30) NOT NULL);