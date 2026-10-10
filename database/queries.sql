-- EarlyWatch example queries
USE earlywatch;

-- Q1: students at medium or high risk, worst first (WHERE + ORDER BY)
SELECT s.student_id, s.name, r.value, r.risk_level
FROM students s
JOIN risk_scores r ON r.student_id = s.student_id
WHERE r.risk_level IN ('high', 'medium')
ORDER BY r.value DESC;

-- Q2: the advisor-scoped view, so advisor A01 only sees their own students
SELECT s.student_id, s.name, a.role, r.value, r.risk_level
FROM advisor_students a
JOIN students s ON s.student_id = a.student_id
LEFT JOIN risk_scores r ON r.student_id = s.student_id
WHERE a.advisor_id = 'A01'
ORDER BY r.value DESC;

-- Q3: students with 2 or more absences (GROUP BY + HAVING)
SELECT student_id, COUNT(*) AS absences
FROM attendance_records
WHERE present = FALSE
GROUP BY student_id
HAVING COUNT(*) >= 2;

-- Q4: attendance rate per student, lowest first (GROUP BY + ORDER BY)
SELECT student_id,
       ROUND(100 * SUM(present) / COUNT(*), 1) AS attendance_rate
FROM attendance_records
GROUP BY student_id
ORDER BY attendance_rate ASC;

-- ============ UPDATE / DELETE examples ============

-- U1: a normal update. The advisor opens the alert, so the status changes
UPDATE alerts SET status = 'viewed' WHERE student_id = 'S004';
SELECT alert_id, student_id, status FROM alerts;

-- U2: CHECK constraint (BR12). A risk value above 100 is rejected. EXPECTED ERROR 3819
UPDATE risk_scores SET value = 150 WHERE student_id = 'S001';

-- U3: trigger (BR13). A future attendance date is rejected. EXPECTED ERROR 1644
INSERT INTO attendance_records (student_id, course_id, date, present)
VALUES ('S001', 'SE202', '2030-01-01', TRUE);

-- D1: ON DELETE RESTRICT. An advisor who still has students cannot be deleted. EXPECTED ERROR 1451
DELETE FROM advisors WHERE advisor_id = 'A01';

-- D2: ON DELETE CASCADE. Deleting a student removes their enrollments and advisor links.
-- Wrapped in a transaction and rolled back, so the sample data stays intact.
START TRANSACTION;
DELETE FROM students WHERE student_id = 'S005';
SELECT 'enrollments left for S005' AS check_name, COUNT(*) AS n FROM enrollments WHERE student_id = 'S005'
UNION ALL
SELECT 'advisor links left for S005', COUNT(*) FROM advisor_students WHERE student_id = 'S005';
ROLLBACK;

-- D3: ON UPDATE CASCADE. Changing a student ID updates every row that points to it.
START TRANSACTION;
UPDATE students SET student_id = 'S099' WHERE student_id = 'S005';
SELECT student_id, course_id FROM enrollments WHERE student_id = 'S099';
ROLLBACK;