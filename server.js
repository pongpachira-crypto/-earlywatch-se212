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

app.listen(PORT, () => {
  console.log(`EarlyWatch running at http://localhost:${PORT}`);
});