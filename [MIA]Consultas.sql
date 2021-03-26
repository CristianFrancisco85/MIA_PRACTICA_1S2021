USE MIA_Practica;

CREATE VIEW Reporte1 AS
SELECT Hospital.Nombre,COUNT(*) AS Fallecidos FROM Registro 
INNER JOIN Victima ON Victima.idVictima = Registro.idVictima 
INNER JOIN Hospital ON Hospital.idHospital = Registro.idHospital
WHERE Victima.Estado = 'Muerte' 
GROUP BY Registro.idHospital;

CREATE VIEW Reporte2 AS
SELECT DISTINCT Victima.Nombres,Victima.Apellidos FROM Victima 
INNER JOIN Registro ON Victima.idVictima = Registro.idVictima
INNER JOIN PersonaTratamiento ON Registro.idRegistro = PersonaTratamiento.idRegistro
INNER JOIN Tratamiento ON PersonaTratamiento.idTratamiento = Tratamiento.idTratamiento
WHERE 
Victima.Estado = 'En cuarentena' 
AND PersonaTratamiento.Efectividad>5
AND Tratamiento.Nombre='Transfusiones de sangre';

CREATE VIEW Reporte3 AS
SELECT DISTINCT Victima.Nombres,Victima.Apellidos,Victima.Direccion,COUNT(*) AS Numero_Asociados FROM Victima 
INNER JOIN VictimaAsociado ON Victima.idVictima = VictimaAsociado.idVictima
INNER JOIN Asociado ON VictimaAsociado.idAsociado = Asociado.idAsociado
GROUP BY Victima.idVictima
HAVING Numero_Asociados>3;

CREATE VIEW Reporte4 AS
SELECT DISTINCT Victima.Nombres,Victima.Apellidos,COUNT(*) AS Numero_Contactos FROM Victima
INNER JOIN VictimaAsociado ON Victima.idVictima = VictimaAsociado.idVictima
INNER JOIN Contacto ON VictimaAsociado.idVictimaAsociado = Contacto.idVictimaAsociado
WHERE
-- Victima.Estado = 'Suspendida'
Contacto.Tipo = 'Beso'
GROUP BY Victima.idVictima
HAVING Numero_Contactos>2;

CREATE VIEW Reporte5 AS
SELECT Victima.*,COUNT(*) AS Cantidad_Aplicaciones FROM Victima
INNER JOIN Registro ON Victima.idVictima = Registro.idVictima
INNER JOIN PersonaTratamiento ON Registro.idRegistro = PersonaTratamiento.idRegistro
INNER JOIN Tratamiento ON PersonaTratamiento.idTratamiento = Tratamiento.idTratamiento
WHERE 
Tratamiento.Nombre='Oxigeno'
GROUP BY Victima.idVictima
ORDER BY Cantidad_Aplicaciones DESC
LIMIT 5;

CREATE VIEW Reporte6 AS
SELECT Victima.Nombres,Victima.Apellidos,Victima.FechaMuerte FROM Victima
INNER JOIN Ubicacion ON Victima.idVictima = Ubicacion.idVictima
WHERE 
Victima.FechaMuerte != '0000-00-00 00:00:00' 
AND Ubicacion.Direccion='1987 Delphine Well';


SELECT * FROM Reporte1;
SELECT * FROM Reporte2;
SELECT * FROM Reporte3;
SELECT * FROM Reporte4;
SELECT * FROM Reporte5;
SELECT * FROM Reporte6;