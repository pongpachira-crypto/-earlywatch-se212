-- EarlyWatch database schema

CREATE DATABASE IF NOT EXISTS earlywatch;
USE earlywatch;

CREATE TABLE students (
  student_id            VARCHAR(20)     PRIMARY KEY,
  name                  VARCHAR(100)    NOT NULL,
  program               VARCHAR(100),
  year                  INT,
  baseline_attendance_rate DECIMAL(5,2) DEFAULT 100.00
);

CREATE TABLE advisors (
  advisor_id            VARCHAR(20)     PRIMARY KEY,
  name                  VARCHAR(100)    NOT NULL,
  department            VARCHAR(100),
  email                 VARCHAR(150)
);

CREATE TABLE instructors (
  instructor_id         VARCHAR(20)     PRIMARY KEY,
  name                  VARCHAR(100)    NOT NULL,
  email                 VARCHAR(150),
  department            VARCHAR(100)
);