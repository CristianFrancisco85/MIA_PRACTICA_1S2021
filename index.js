const mysql = require('mysql');
const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'passwd',
  database: 'MIA_Practica'
});
connection.connect((err) => {
  if (err) throw err;
  console.log('Connected!');
});
