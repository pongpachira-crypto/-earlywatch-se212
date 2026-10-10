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