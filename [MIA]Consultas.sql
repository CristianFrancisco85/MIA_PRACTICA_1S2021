USE MIA_Practica;

-- ******************************************************************
-- Vista del Reporte 1
-- ******************************************************************
CREATE OR REPLACE VIEW Reporte1 AS
SELECT Hospital.Nombre,COUNT(*) AS Fallecidos FROM Registro 
INNER JOIN Victima ON Victima.idVictima = Registro.idVictima 
INNER JOIN Hospital ON Hospital.idHospital = Registro.idHospital
WHERE Victima.Estado = 'Muerte' 
GROUP BY Registro.idHospital;

-- ******************************************************************
-- Vista del Reporte 3
-- ******************************************************************
CREATE OR REPLACE VIEW Reporte2 AS
SELECT DISTINCT Victima.Nombres,Victima.Apellidos FROM Victima 
INNER JOIN Registro ON Victima.idVictima = Registro.idVictima
INNER JOIN PersonaTratamiento ON Registro.idRegistro = PersonaTratamiento.idRegistro
INNER JOIN Tratamiento ON PersonaTratamiento.idTratamiento = Tratamiento.idTratamiento
WHERE 
Victima.Estado = 'En cuarentena' 
AND PersonaTratamiento.Efectividad>5
AND Tratamiento.Nombre='Transfusiones de sangre';

-- ******************************************************************
-- Vista del Reporte 3
-- ******************************************************************
CREATE OR REPLACE VIEW Reporte3 AS
SELECT Victima.Nombres,Victima.Apellidos,Victima.Direccion,COUNT(*) AS Numero_Asociados FROM Victima 
INNER JOIN VictimaAsociado ON Victima.idVictima = VictimaAsociado.idVictima
INNER JOIN Asociado ON VictimaAsociado.idAsociado = Asociado.idAsociado
GROUP BY Victima.idVictima
HAVING Numero_Asociados>3;

-- ******************************************************************
-- Vista del Reporte 4
-- ******************************************************************
CREATE OR REPLACE VIEW Reporte4 AS
SELECT DISTINCT Victima.Nombres,Victima.Apellidos,COUNT(*) AS Numero_Contactos FROM Victima
INNER JOIN VictimaAsociado ON Victima.idVictima = VictimaAsociado.idVictima
INNER JOIN Contacto ON VictimaAsociado.idVictimaAsociado = Contacto.idVictimaAsociado
WHERE
-- Victima.Estado = 'Suspendida'
Contacto.Tipo = 'Beso'
GROUP BY Victima.idVictima
HAVING Numero_Contactos>2;

-- ******************************************************************
-- Vista del Reporte 5
-- ******************************************************************
CREATE OR REPLACE VIEW Reporte5 AS
SELECT Victima.*,COUNT(*) AS Cantidad_Aplicaciones FROM Victima
INNER JOIN Registro ON Victima.idVictima = Registro.idVictima
INNER JOIN PersonaTratamiento ON Registro.idRegistro = PersonaTratamiento.idRegistro
INNER JOIN Tratamiento ON PersonaTratamiento.idTratamiento = Tratamiento.idTratamiento
WHERE 
Tratamiento.Nombre='Oxigeno'
GROUP BY Victima.idVictima
ORDER BY Cantidad_Aplicaciones DESC
LIMIT 5;

-- ******************************************************************
-- Vista del Reporte 6
-- ******************************************************************
CREATE OR REPLACE VIEW Reporte6 AS
SELECT Victima.Nombres,Victima.Apellidos,Victima.FechaMuerte FROM Victima
INNER JOIN Ubicacion ON Victima.idVictima = Ubicacion.idVictima
WHERE 
Victima.FechaMuerte != '0000-00-00 00:00:00' 
AND Ubicacion.Direccion='1987 Delphine Well';

-- ******************************************************************
-- Vista del Reporte 9
-- ******************************************************************
DROP FUNCTION IF EXISTS getTotalFallecidos;
DELIMITER $$
CREATE FUNCTION getTotalFallecidos() RETURNS INT DETERMINISTIC
BEGIN

	RETURN (
		SELECT SUM(Fallecidos) FROM (
		SELECT COUNT(*) AS Fallecidos FROM Registro 
		INNER JOIN Victima ON Victima.idVictima = Registro.idVictima 
		INNER JOIN Hospital ON Hospital.idHospital = Registro.idHospital
		WHERE Victima.Estado = 'Muerte' 
		GROUP BY Registro.idHospital) AS A
    );
		
END $$
DELIMITER ;

CREATE OR REPLACE VIEW Reporte9 AS
SELECT Hospital.Nombre, concat((COUNT(*)*100/getTotalFallecidos()),' %')AS Porcentaje_Fallecidos FROM Registro 
INNER JOIN Victima ON Victima.idVictima = Registro.idVictima 
INNER JOIN Hospital ON Hospital.idHospital = Registro.idHospital
WHERE Victima.Estado = 'Muerte' 
GROUP BY Registro.idHospital;

-- ******************************************************************
-- Vista del Reporte 10
-- ******************************************************************
DROP PROCEDURE IF EXISTS getContactos;

DELIMITER $$

CREATE PROCEDURE getContactos()
BEGIN

	DROP TEMPORARY TABLE IF EXISTS Temp_Table;
	CREATE TEMPORARY TABLE Temp_Table (
		ID_Hospital int,
		Nombre_Hospital VARCHAR(100),
		Tipo_Contacto VARCHAR(100),
		Porcentaje VARCHAR(100)
	);
    
	INSERT INTO Temp_Table(ID_Hospital,Nombre_Hospital,Tipo_Contacto,Porcentaje)(
		SELECT Nombre,Tipo,MAX(Numero_Contactos) FROM (
			SELECT Hospital.Nombre,Contacto.Tipo,COUNT(*) AS Numero_Contactos FROM Hospital
			INNER JOIN Registro ON Hospital.idHospital = Registro.idHospital
			INNER JOIN Victima ON Registro.idVictima = Victima.idVictima
			INNER JOIN VictimaAsociado ON Victima.idVictima = VictimaAsociado.idVictima
			INNER JOIN Contacto ON VictimaAsociado.idVictimaAsociado = Contacto.idVictimaAsociado
			WHERE Hospital.idHospital NOT IN (SELECT Temp_Table.ID_Hospital FROM Temp_Table)
			GROUP BY Hospital.Nombre,Contacto.Tipo
			ORDER BY Hospital.Nombre,Numero_contactos DESC
        ) AS AUX1
        GROUP BY Nombre,Tipo
    );
    
    SELECT Nombre_Hospital,Tipo_Contacto,Porcentaje FROM Temp_Table;
        
END $$

DELIMITER ;


SELECT Hospital.Nombre FROM Hospital

GROUP BY Hospital.Nombre,Contacto.Tipo;



SELECT * FROM Reporte1;
SELECT * FROM Reporte2;
SELECT * FROM Reporte3;
SELECT * FROM Reporte4;
SELECT * FROM Reporte5;
SELECT * FROM Reporte6;


SELECT * FROM Reporte9;