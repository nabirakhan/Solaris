require('dotenv').config();
const { pool } = require('./config/database');

console.log('Testing database connection...\n');

pool.query('SELECT COUNT(*) FROM users', (err, res) => {
  if (err) {
    console.error('❌ Database query failed:', err.message);
  } else {
    console.log('✅ Database connected!');
    console.log('📊 Number of users in database:', res.rows[0].count);
  }
  pool.end();
});