const express = require('express');
const pool = require('./db');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.static('public'));

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
      `SELECT s.student_id, s.name, a.role,
              r.value AS risk_value, r.risk_level, r.week
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

app.listen(PORT, () => {
  console.log(`EarlyWatch running at http://localhost:${PORT}`);
});