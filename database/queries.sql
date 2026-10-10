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