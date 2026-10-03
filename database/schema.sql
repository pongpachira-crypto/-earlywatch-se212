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

CREATE TABLE courses (
  course_id             VARCHAR(20)     PRIMARY KEY,
  course_name           VARCHAR(150)    NOT NULL,
  semester              VARCHAR(20),
  instructor_id         VARCHAR(20),
  FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id)
);

CREATE TABLE assignments (
  assignment_id         INT AUTO_INCREMENT PRIMARY KEY,
  course_id             VARCHAR(20)     NOT NULL,
  title                 VARCHAR(150)    NOT NULL,
  due_date              DATE,
  FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

CREATE TABLE enrollments (
  student_id            VARCHAR(20)     NOT NULL,
  course_id             VARCHAR(20)     NOT NULL,
  semester              VARCHAR(20),
  enrolled_date         DATE,
  PRIMARY KEY (student_id, course_id),
  FOREIGN KEY (student_id) REFERENCES students(student_id),
  FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

CREATE TABLE advisor_students (
  advisor_id            VARCHAR(20)     NOT NULL,
  student_id            VARCHAR(20)     NOT NULL,
  assigned_date         DATE,
  role                  ENUM('primary', 'co-advisor') NOT NULL,
  PRIMARY KEY (advisor_id, student_id),
  FOREIGN KEY (advisor_id) REFERENCES advisors(advisor_id),
  FOREIGN KEY (student_id) REFERENCES students(student_id)
);