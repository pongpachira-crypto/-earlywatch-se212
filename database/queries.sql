-- EarlyWatch example queries
USE earlywatch;

-- Q1: risk scores at medium or high, worst first (WHERE + ORDER BY)
SELECT s.student_id, s.name, r.value, r.risk_level
FROM students s
JOIN risk_scores r ON r.student_id = s.student_id
WHERE r.risk_level IN ('high', 'medium')
ORDER BY r.value DESC;

-- Q2: advisor A01's students with their latest risk (JOIN through the bridge table + LEFT JOIN)
SELECT s.student_id, s.name, adv.role, r.value, r.risk_level
FROM advisor_students adv
JOIN students s ON s.student_id = adv.student_id
LEFT JOIN risk_scores r
  ON r.student_id = s.student_id
 AND r.week = (SELECT MAX(week) FROM risk_scores WHERE student_id = s.student_id)
WHERE adv.advisor_id = 'A01'
ORDER BY r.value DESC;

-- Q3: students with 2 or more absences (GROUP BY + HAVING)
SELECT student_id, COUNT(*) AS absences
FROM attendance_records
WHERE present = FALSE
GROUP BY student_id
HAVING COUNT(*) >= 2;

-- Q4: attendance rate per student (aggregate over a boolean)
SELECT student_id,
       ROUND(100 * SUM(present) / COUNT(*), 2) AS attendance_rate
FROM attendance_records
GROUP BY student_id;

-- Q5: students whose risk score is rising this week (self-join, compares with the week before)
SELECT s.student_id, s.name, r.value AS this_week, p.value AS last_week,
       r.value - p.value AS difference
FROM risk_scores r
JOIN risk_scores p ON p.student_id = r.student_id
                  AND p.week = DATE_SUB(r.week, INTERVAL 7 DAY)
JOIN students s ON s.student_id = r.student_id
WHERE r.week = '2026-09-07' AND r.value > p.value
ORDER BY difference DESC;

-- ============ UPDATE / DELETE examples ============

-- U1: a normal update. The advisor opens the alert, so the status changes
UPDATE alerts SET status = 'viewed' WHERE alert_id = 1;
SELECT alert_id, student_id, status FROM alerts;

-- U2: CHECK constraint (BR12). A risk value above 100 is rejected. EXPECTED ERROR 3819
UPDATE risk_scores SET value = 150 WHERE student_id = 'S004' AND week = '2026-09-07';

-- U3: trigger (BR13). A future attendance date is rejected. EXPECTED ERROR 1644
INSERT INTO attendance_records (student_id, course_id, date, present)
VALUES ('S001', 'SE202', '2030-01-01', TRUE);

-- D1: ON DELETE RESTRICT. An advisor who still has students cannot be deleted. EXPECTED ERROR 1451
DELETE FROM advisors WHERE advisor_id = 'A01';

-- D2: ON DELETE CASCADE. Deleting a student removes their dependent rows.
-- Wrapped in a transaction and rolled back, so the sample data stays intact.
START TRANSACTION;
DELETE FROM students WHERE student_id = 'S004';
SELECT COUNT(*) FROM attendance_records WHERE student_id = 'S004';  -- 0
SELECT COUNT(*) FROM alerts WHERE student_id = 'S004';              -- 0
ROLLBACK;

-- D3: ON UPDATE CASCADE. Changing a student ID updates every row that points to it.
START TRANSACTION;
UPDATE students SET student_id = 'S999' WHERE student_id = 'S004';
SELECT COUNT(*) FROM attendance_records WHERE student_id = 'S999';  -- 4
ROLLBACK;