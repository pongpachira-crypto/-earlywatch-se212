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

CREATE TABLE attendance_records (
  attendance_id         INT AUTO_INCREMENT PRIMARY KEY,
  student_id            VARCHAR(20)     NOT NULL,
  course_id             VARCHAR(20)     NOT NULL,
  date                  DATE            NOT NULL,
  present               BOOLEAN         NOT NULL,
  FOREIGN KEY (student_id) REFERENCES students(student_id),
  FOREIGN KEY (course_id) REFERENCES courses(course_id),
  UNIQUE (student_id, course_id, date),
  CONSTRAINT chk_attendance_date_not_future CHECK (date <= CURDATE())
);

CREATE TABLE submissions (
  submission_id         INT AUTO_INCREMENT PRIMARY KEY,
  student_id            VARCHAR(20)     NOT NULL,
  assignment_id         INT             NOT NULL,
  submitted_at          DATETIME        NOT NULL,
  is_late               BOOLEAN         DEFAULT FALSE,
  FOREIGN KEY (student_id) REFERENCES students(student_id),
  FOREIGN KEY (assignment_id) REFERENCES assignments(assignment_id)
);

CREATE TABLE risk_scores (
  risk_score_id         INT AUTO_INCREMENT PRIMARY KEY,
  student_id            VARCHAR(20)     NOT NULL,
  week                  DATE            NOT NULL,
  value                 DECIMAL(5,2)    NOT NULL,
  risk_level            ENUM('low', 'medium', 'high') NOT NULL,
  computed_at           DATETIME        DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(student_id),
  UNIQUE (student_id, week),
  CONSTRAINT chk_risk_value_range CHECK (value BETWEEN 0 AND 100)
);