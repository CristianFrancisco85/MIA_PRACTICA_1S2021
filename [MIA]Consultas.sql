USE MIA_Practica;

-- ******************************************************************
-- Vista del Reporte 1
-- ******************************************************************
CREATE OR REPLACE VIEW Reporte1 AS(
SELECT Hospital.Nombre,COUNT(*) AS Fallecidos FROM Registro 
INNER JOIN Victima ON Victima.idVictima = Registro.idVictima 
INNER JOIN Hospital ON Hospital.idHospital = Registro.idHospital
WHERE Victima.FechaMuerte != '0000-00-00 00:00:00' 
GROUP BY Hospital.Nombre);

-- ******************************************************************
-- Vista del Reporte 2
-- ******************************************************************
CREATE OR REPLACE VIEW Reporte2 AS(
SELECT DISTINCT Victima.Nombres,Victima.Apellidos FROM Victima 
INNER JOIN Registro ON Victima.idVictima = Registro.idVictima
INNER JOIN PersonaTratamiento ON Registro.idRegistro = PersonaTratamiento.idRegistro
INNER JOIN Tratamiento ON PersonaTratamiento.idTratamiento = Tratamiento.idTratamiento
WHERE 
Victima.Estado = 'En cuarentena' 
AND PersonaTratamiento.Efectividad>5
AND Tratamiento.Nombre='Transfusiones de sangre');

-- ******************************************************************
-- Vista del Reporte 3
-- ******************************************************************
CREATE OR REPLACE VIEW Reporte3 AS(
SELECT Victima.Nombres,Victima.Apellidos,Victima.Direccion,COUNT(*) AS Numero_Asociados FROM Victima 
INNER JOIN VictimaAsociado ON VictimaAsociado.idVictima = Victima.idVictima
INNER JOIN Asociado ON Asociado.idAsociado = VictimaAsociado.idAsociado
WHERE Victima.FechaMuerte != '0000-00-00 00:00:00' 
GROUP BY Victima.idVictima
HAVING Numero_Asociados>3);

-- ******************************************************************
-- Vista del Reporte 4
-- ******************************************************************
CREATE OR REPLACE VIEW Reporte4 AS(
SELECT Victima.Nombres,Victima.Apellidos,COUNT(*) AS Numero_Contactos FROM Victima
INNER JOIN VictimaAsociado ON Victima.idVictima = VictimaAsociado.idVictima
INNER JOIN Contacto ON VictimaAsociado.idVictimaAsociado = Contacto.idVictimaAsociado
WHERE
Victima.Estado = 'Sospecha'
AND
Contacto.Tipo = 'Beso'
GROUP BY Victima.idVictima
HAVING Numero_Contactos > 2 );

-- ******************************************************************
-- Vista del Reporte 5
-- ******************************************************************
CREATE OR REPLACE VIEW Reporte5 AS(
SELECT Victima.*,COUNT(*) AS Cantidad_Aplicaciones FROM Victima
INNER JOIN Registro ON Victima.idVictima = Registro.idVictima
INNER JOIN PersonaTratamiento ON Registro.idRegistro = PersonaTratamiento.idRegistro
INNER JOIN Tratamiento ON PersonaTratamiento.idTratamiento = Tratamiento.idTratamiento
WHERE 
Tratamiento.Nombre='Oxigeno'
GROUP BY Victima.idVictima
ORDER BY Cantidad_Aplicaciones DESC
LIMIT 5);

-- ******************************************************************
-- Vista del Reporte 6
-- ******************************************************************
CREATE OR REPLACE VIEW Reporte6 AS(
SELECT Victima.Nombres,Victima.Apellidos,Victima.FechaMuerte FROM Victima
INNER JOIN Ubicacion ON Victima.idVictima = Ubicacion.idVictima
INNER JOIN Registro ON Victima.idVictima = Registro.idVictima
INNER JOIN PersonaTratamiento ON Registro.idRegistro = PersonaTratamiento.idRegistro
INNER JOIN Tratamiento ON PersonaTratamiento.idTratamiento = Tratamiento.idTratamiento
WHERE 
Victima.FechaMuerte != '0000-00-00 00:00:00' 
AND Ubicacion.Direccion='1987 Delphine Well'
AND Tratamiento.Nombre='Manejo de la presion arterial');

-- ******************************************************************
-- Vista del Reporte 7
-- ******************************************************************
CREATE OR REPLACE VIEW Reporte7 AS(
SELECT Victima.Nombres,Victima.Apellidos,Victima.Direccion FROM Registro
INNER JOIN Victima ON  Registro.idVictima = Victima.idVictima
WHERE getNumAllegados(Victima.idVictima)<2 AND getNumTratamientos(Victima.idVictima)=2);

-- ******************************************************************
-- Vista del Reporte 8
-- ******************************************************************
CREATE OR REPLACE VIEW Reporte8 AS(
	(SELECT Victima.Nombres,Victima.Apellidos,MONTH(Victima.FechaSospecha) AS Mes, getNumTratamientos(Victima.idVictima) AS Tratamientos FROM Victima
	ORDER BY getNumTratamientos(Victima.idVictima) DESC
	LIMIT 5)
	UNION
	(SELECT Victima.Nombres,Victima.Apellidos,MONTH(Victima.FechaSospecha) AS Mes,getNumTratamientos(Victima.idVictima) AS Tratamientos FROM Victima
	ORDER BY getNumTratamientos(Victima.idVictima) ASC
	LIMIT 5)
);

-- ******************************************************************
-- Vista del Reporte 9
-- ******************************************************************
CREATE OR REPLACE VIEW Reporte9 AS(
SELECT Hospital.Nombre, CONCAT((COUNT(*)*100/getTotalRegistrados()),' %')AS Porcentaje_Fallecidos FROM Registro 
INNER JOIN Victima ON Victima.idVictima = Registro.idVictima 
INNER JOIN Hospital ON Hospital.idHospital = Registro.idHospital
GROUP BY Registro.idHospital);

-- ******************************************************************
-- Vista del Reporte 10
-- ******************************************************************
CREATE OR REPLACE VIEW Reporte10 AS(
SELECT Hospital.Nombre,getMaxContactoTipo(Hospital.Nombre),CONCAT(getMaxContacto(Hospital.Nombre),'%') AS Porcentaje FROM Hospital
INNER JOIN Registro ON Hospital.idHospital = Registro.idHospital
INNER JOIN Victima ON Registro.idVictima = Victima.idVictima
INNER JOIN VictimaAsociado ON Victima.idVictima = VictimaAsociado.idVictima
INNER JOIN Contacto ON VictimaAsociado.idVictimaAsociado = Contacto.idVictimaAsociado
GROUP BY Hospital.Nombre
ORDER BY Hospital.Nombre,Porcentaje ASC);

