const mysql = require('mysql');
const express = require('express');
const fs = require('fs');
const path = require('path');

const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'passwd',
  database: 'MIA_Practica',
  multipleStatements: true
});

connection.connect((err) => {
  if(err){
    console.log('[ERROR] No se pudo conectar con la base de datos');
    return;
  }
  else{
    console.log('[OK] Conexion exitosa a base de datos');
  }
});

const app = express();

app.use(express.json());
app.use(express.urlencoded());


app.get("/", (req, res) => {
  res.json({ message: "[OK] API lista para recibir peticiones" });
});

app.get('/cargarTemporal', async(req, res) => {

  const sqlContent = fs.readFileSync(path.join(__dirname, '[MIA]CargaDeDatos.sql'),'ascii');

  const query = await connection.query(sqlContent,(err, result) => {
      if (err){
        res.send({ message: err });
      }
      else{
        res.send({ message: "[OK] Datos cargados exitosamente a tabla temporal" });
      }
  });
});

app.get('/cargarModelo', async(req, res) => {
  
  const sqlContent = fs.readFileSync(path.join(__dirname, '[MIA]InstruccionesDDL.sql'),'ascii') + fs.readFileSync(path.join(__dirname, '[MIA]Consultas.sql'),'ascii');

  const query = await connection.query(sqlContent,(err, result) => {
      if (err){
        res.send(err);
      }
      else{
        res.send({ message: "[OK] Se ha creado el modelo ER y cargado con la informacion" });
      }
  });
});

app.get('/eliminarModelo', async(req, res) => {

  const query = await connection.query('CALL dropModel();',(err, result) => {
      if (err){
        res.send({ message: err });
      }
      else{
        res.send({ message: "[OK] Modelo eliminado exitosamente" });
      }
  });
});

app.get('/eliminarTemporal', async(req, res) => {

  const query = await connection.query('DELETE FROM CSVTable WHERE idTemp>0;',(err, result) => {
      if (err){
        res.send({ message: err });
      }
      else{
        res.send({ message: "[OK] Se han eliminado datos de la tabla temporal" });
      }
  });
});

app.get('/consulta1', async(req, res) => {

  const query = await connection.query('SELECT * FROM Reporte1;',(err, result) => {
      if (err){
        res.send({ message: err });
      }
      else{
        res.send(result);
      }
  });
});

app.get('/consulta2', async(req, res) => {

  const query = await connection.query('SELECT * FROM Reporte2;',(err, result) => {
      if (err){
        res.send({ message: err });
      }
      else{
        res.send(result);
      }
  });
});

app.get('/consulta3', async(req, res) => {

  const query = await connection.query('SELECT * FROM Reporte3;',(err, result) => {
      if (err){
        res.send({ message: err });
      }
      else{
        res.send(result);
      }
  });
});

app.get('/consulta4', async(req, res) => {

  const query = await connection.query('SELECT * FROM Reporte4;',(err, result) => {
      if (err){
        res.send({ message: err });
      }
      else{
        res.send(result);
      }
  });
});

app.get('/consulta5', async(req, res) => {

  const query = await connection.query('SELECT * FROM Reporte5;',(err, result) => {
      if (err){
        res.send({ message: err });
      }
      else{
        res.send(result);
      }
  });
});

app.get('/consulta6', async(req, res) => {

  const query = await connection.query('SELECT * FROM Reporte6;',(err, result) => {
      if (err){
        res.send({ message: err });
      }
      else{
        res.send(result);
      }
  });
});

app.get('/consulta7', async(req, res) => {

  const query = await connection.query('SELECT * FROM Reporte7;',(err, result) => {
      if (err){
        res.send({ message: err });
      }
      else{
        res.send(result);
      }
  });
});

app.get('/consulta8', async(req, res) => {

  const query = await connection.query('SELECT * FROM Reporte8;',(err, result) => {
      if (err){
        res.send({ message: err });
      }
      else{
        res.send(result);
      }
  });
});

app.get('/consulta9', async(req, res) => {

  const query = await connection.query('SELECT * FROM Reporte9;',(err, result) => {
      if (err){
        res.send({ message: err });
      }
      else{
        res.send(result);
      }
  });
});

app.get('/consulta10', async(req, res) => {

  const query = await connection.query('SELECT * FROM Reporte10;',(err, result) => {
      if (err){
        res.send({ message: err });
      }
      else{
        res.send(result);
      }
  });
});

app.listen(3000, () => {
  console.log("[OK] API inicializada en puerto 3000");
});