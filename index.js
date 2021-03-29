const mysql = require('mysql');
const express = require('express');

const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'passwd',
  database: 'MIA_Practica'
});

connection.connect((err) => {
  if(err){
    console.log('Error al conectarse a la base de datos');
    return;
  }
  else{
    console.log('Conexion exitosa a base de datos');
  }
});

const app = express();

app.use(express.json());
app.use(express.urlencoded());


app.get("/", (req, res) => {
  res.json({ message: "API lista para recibir peticiones" });
});

app.listen(3000, () => {
  console.log("Server is running on port 3000.");
});