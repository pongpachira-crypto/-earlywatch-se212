const express = require('express');
const pool = require('./db');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.static('public'));
app.use(express.json());

// List all students
app.get('/api/students', async (req, res) => {
  try {
    const [rows] = await pool.execute(
      'SELECT student_id, name, program, year FROM students ORDER BY student_id'
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

// An advisor sees only their own students, with each student's latest risk score
app.get('/api/advisors/:advisorId/students', async (req, res) => {
  try {
    const [rows] = await pool.execute(
      `SELECT s.student_id, s.name, s.baseline_attendance_rate, a.role,
              r.value AS risk_score, r.risk_level, r.week
       FROM advisor_students a
       JOIN students s ON s.student_id = a.student_id
       LEFT JOIN risk_scores r ON r.student_id = s.student_id
         AND r.week = (SELECT MAX(week) FROM risk_scores WHERE student_id = s.student_id)
       WHERE a.advisor_id = ?
       ORDER BY r.value DESC`,
      [req.params.advisorId]
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

// Weekly risk score history for one student
app.get('/api/students/:studentId/risk-scores', async (req, res) => {
  try {
    const [rows] = await pool.execute(
      `SELECT week, value, risk_level, computed_at
       FROM risk_scores
       WHERE student_id = ?
       ORDER BY week`,
      [req.params.studentId]
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

// List one student's attendance records
app.get('/api/students/:studentId/attendance', async (req, res) => {
  try {
    const [rows] = await pool.execute(
      `SELECT attendance_id, course_id, date, present
       FROM attendance_records
       WHERE student_id = ?
       ORDER BY date DESC`,
      [req.params.studentId]
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

// Alerts sent to one advisor (advisor sees only their own alerts)
app.get('/api/advisors/:advisorId/alerts', async (req, res) => {
  try {
    const [rows] = await pool.execute(
      `SELECT al.alert_id, al.student_id, s.name, al.sent_at, al.status
       FROM alerts al
       JOIN students s ON s.student_id = al.student_id
       WHERE al.advisor_id = ?
       ORDER BY al.sent_at DESC`,
      [req.params.advisorId]
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

// Advisor marks an alert as viewed or followed up (supports objective O5)
app.patch('/api/alerts/:alertId', async (req, res) => {
  const { status } = req.body || {};
  if (!['viewed', 'followed_up'].includes(status)) {
    return res.status(400).json({ error: "status must be 'viewed' or 'followed_up'" });
  }
  try {
    const [result] = await pool.execute(
      'UPDATE alerts SET status = ? WHERE alert_id = ?',
      [status, req.params.alertId]
    );
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Alert not found' });
    }
    res.json({ alert_id: Number(req.params.alertId), status });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

// Add an attendance record (the trigger and constraints can reject it)
app.post('/api/attendance', async (req, res) => {
  const { student_id, course_id, date, status } = req.body || {};
  if (!student_id || !course_id || !date || !['present', 'absent'].includes(status)) {
    return res.status(400).json({ error: 'student_id, course_id, date and status are required' });
  }
  try {
    const [result] = await pool.execute(
      'INSERT INTO attendance_records (student_id, course_id, date, present) VALUES (?, ?, ?, ?)',
      [student_id, course_id, date, status === 'present' ? 1 : 0]
    );
    res.status(201).json({ attendance_id: result.insertId });
  } catch (err) {
    // sqlMessage carries the database's own message, e.g.
    // "Attendance date cannot be in the future (BR13)"
    res.status(400).json({ error: err.sqlMessage || 'Database error' });
  }
});

// Delete an attendance record
app.delete('/api/attendance/:attendanceId', async (req, res) => {
  try {
    const [result] = await pool.execute(
      'DELETE FROM attendance_records WHERE attendance_id = ?',
      [req.params.attendanceId]
    );
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Record not found' });
    }
    res.json({ ok: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

app.listen(PORT, () => {
  console.log(`EarlyWatch running at http://localhost:${PORT}`);
});