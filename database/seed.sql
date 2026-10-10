-- EarlyWatch sample data: fully synthetic, no real students
USE earlywatch;

INSERT INTO instructors (instructor_id, name, email, department) VALUES
('I01', 'Dr. Anan Suksawat', 'anan@cmu.ac.th', 'Computer Engineering'),
('I02', 'Dr. Kanya Rattana', 'kanya@cmu.ac.th', 'Software Engineering'),
('I03', 'Dr. Prem Wichai', 'prem@cmu.ac.th', 'Computer Engineering');

INSERT INTO advisors (advisor_id, name, department, email) VALUES
('A01', 'Dr. Somchai Dee', 'Software Engineering', 'somchai@cmu.ac.th'),
('A02', 'Dr. Rattana Phon', 'Software Engineering', 'rattana@cmu.ac.th');

INSERT INTO students (student_id, name, program, year, baseline_attendance_rate) VALUES
('S001', 'Ploy Sriwan', 'SE', 2, 92.00),
('S002', 'Nat Wongchai', 'SE', 2, 88.50),
('S003', 'Mook Chaiyaporn', 'SE', 3, 95.00),
('S004', 'Film Kittipong', 'SE', 2, 70.00),
('S005', 'Ice Supaporn', 'SE', 1, 90.00);

INSERT INTO courses (course_id, course_name, semester, instructor_id) VALUES
('SE101', 'Intro to Software Engineering', '1/2026', 'I01'),
('SE202', 'Database Systems', '1/2026', 'I02'),
('SE303', 'Computer Networks', '1/2026', 'I03');

INSERT INTO assignments (course_id, title, due_date) VALUES
('SE202', 'Lab 1: ER Diagram', '2026-09-20'),
('SE202', 'Lab 2: Normalization', '2026-09-27'),
('SE101', 'Assignment 1: Requirements Doc', '2026-09-18');

INSERT INTO enrollments (student_id, course_id, semester, enrolled_date) VALUES
('S001', 'SE101', '1/2026', '2026-08-15'),
('S001', 'SE202', '1/2026', '2026-08-15'),
('S002', 'SE202', '1/2026', '2026-08-16'),
('S003', 'SE101', '1/2026', '2026-08-15'),
('S003', 'SE303', '1/2026', '2026-08-16'),
('S004', 'SE202', '1/2026', '2026-08-17'),
('S005', 'SE101', '1/2026', '2026-08-15');

INSERT INTO advisor_students (advisor_id, student_id, assigned_date, role) VALUES
('A01', 'S001', '2026-08-01', 'primary'),
('A01', 'S002', '2026-08-01', 'primary'),
('A01', 'S004', '2026-08-01', 'primary'),
('A02', 'S003', '2026-08-01', 'primary'),
('A02', 'S005', '2026-08-01', 'primary'),
('A02', 'S004', '2026-08-01', 'co-advisor');

('S004', 'SE202', '2026-09-01', TRUE),
('S004', 'SE202', '2026-09-03', FALSE),
('S004', 'SE202', '2026-09-08', FALSE),
('S004', 'SE202', '2026-09-10', FALSE),
('S001', 'SE202', '2026-09-01', TRUE),
('S001', 'SE202', '2026-09-03', TRUE);

INSERT INTO submissions (student_id, assignment_id, submitted_at, is_late)
SELECT 'S001', assignment_id, '2026-09-19 22:10:00', FALSE
FROM assignments WHERE title = 'Lab 1: ER Diagram';

INSERT INTO submissions (student_id, assignment_id, submitted_at, is_late)
SELECT 'S002', assignment_id, '2026-09-21 09:00:00', TRUE
FROM assignments WHERE title = 'Lab 1: ER Diagram';

INSERT INTO risk_scores (student_id, week, value, risk_level, computed_at) VALUES
('S004', '2026-09-07', 72.00, 'high',   '2026-09-14 06:00:00'),
('S001', '2026-09-07', 15.00, 'low',    '2026-09-14 06:00:00'),
('S002', '2026-09-07', 40.00, 'medium', '2026-09-14 06:00:00');

INSERT INTO alerts (student_id, risk_score_id, advisor_id, sent_at, status)
SELECT 'S004', risk_score_id, 'A01', '2026-09-14 07:00:00', 'sent'
FROM risk_scores WHERE student_id = 'S004' AND week = '2026-09-07';