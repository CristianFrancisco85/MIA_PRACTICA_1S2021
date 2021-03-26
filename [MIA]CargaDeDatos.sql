
USE MIA_Practica;

-- ******************************************************************
-- Se crea tabla temporal para la carga de datos desde el archivo CSV
-- ******************************************************************
DROP TEMPORARY TABLE IF EXISTS CSVTable;
CREATE TEMPORARY TABLE CSVTable(
idTemp INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
NOMBRE_VICTIMA VARCHAR(50) NOT NULL,
APELLIDO_VICTIMA VARCHAR(50) NOT NULL,
DIRECCION_VICTIMA VARCHAR(250) NOT NULL,
FECHA_PRIMERA_SOSPECHA DATETIME NOT NULL,
FECHA_CONFIRMACION DATETIME NOT NULL,
FECHA_MUERTE DATETIME DEFAULT NULL,
ESTADO_VICTIMA VARCHAR(50) NOT NULL,
NOMBRE_ASOCIADO VARCHAR(50),
APELLIDO_ASOCIADO VARCHAR(50),
FECHA_CONOCIO DATETIME,
CONTACTO_FISICO VARCHAR(25),
FECHA_INICIO_CONTACTO DATETIME,
FECHA_FIN_CONTACTO DATETIME,
NOMBRE_HOSPITAL VARCHAR(100),
DIRECCION_HOSPITAL VARCHAR(250),
UBICACION_VICTIMA VARCHAR(250),
FECHA_LLEGADA DATETIME,
FECHA_RETIRO DATETIME,
TRATAMIENTO VARCHAR(100),
EFECTIVIDAD INT,
FECHA_INICIO_TRATAMIENTO DATETIME,
FECHA_FIN_TRATAMIENTO DATETIME,
EFECTIVIDAD_EN_VICTIMA INT
);

-- ******************************************************************
-- Se carga datos del archivo CSV en la tabla temporal CSVTable
-- ******************************************************************

LOAD DATA LOCAL INFILE '/home/cristian/Descargas/GRAND_VIRUS_EPICENTER.csv' 
INTO TABLE CSVTable
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES(
NOMBRE_VICTIMA,
APELLIDO_VICTIMA,
DIRECCION_VICTIMA,
FECHA_PRIMERA_SOSPECHA,
FECHA_CONFIRMACION,
FECHA_MUERTE,
ESTADO_VICTIMA,
NOMBRE_ASOCIADO,
APELLIDO_ASOCIADO,
FECHA_CONOCIO,
CONTACTO_FISICO,
FECHA_INICIO_CONTACTO,
FECHA_FIN_CONTACTO,
NOMBRE_HOSPITAL,
DIRECCION_HOSPITAL,
UBICACION_VICTIMA,
FECHA_LLEGADA,
FECHA_RETIRO,
TRATAMIENTO,
EFECTIVIDAD,
FECHA_INICIO_TRATAMIENTO,
FECHA_FIN_TRATAMIENTO,
EFECTIVIDAD_EN_VICTIMA
);

-- SELECT * FROM CSVTable;

-- ******************************************************************
-- Funciones para Obtener ID's 
-- ******************************************************************
DELIMITER $$

CREATE FUNCTION getVictimaID(nombres varchar(50),apellidos varchar(50)) RETURNS INT DETERMINISTIC
BEGIN

	RETURN(
    SELECT idVictima FROM Victima
    WHERE Victima.Nombres = nombres AND Victima.Apellidos = apellidos
    );
	
END $$

CREATE FUNCTION getAsociadoID(nombres varchar(50),apellidos varchar(50)) RETURNS INT DETERMINISTIC
BEGIN

	RETURN(
    SELECT idAsociado FROM Asociado
    WHERE Asociado.Nombres = nombres AND Asociado.Apellidos = apellidos
    );
	
END $$

CREATE FUNCTION getHospitalID(nombre varchar(100)) RETURNS INT DETERMINISTIC
BEGIN

	RETURN(
    SELECT idHospital FROM Hospital
    WHERE Hospital.Nombre = nombre
    );
	
END $$

CREATE FUNCTION getRegistroID(idHospital int,idVictima int) RETURNS INT DETERMINISTIC
BEGIN

	RETURN(
    SELECT idRegistro FROM Registro
    WHERE 
    Registro.idHospital = idHospital
    AND Registro.idVictima = idVictima
    );
	
END $$

CREATE FUNCTION getVictimaAsociadoID(idVictima int,idAsociado int) RETURNS INT DETERMINISTIC
BEGIN

	RETURN(
    SELECT idVictimaAsociado FROM VictimaAsociado
    WHERE 
    VictimaAsociado.idVictima = idVictima
    AND VictimaAsociado.idAsociado = idAsociado
    );
	
END $$

CREATE FUNCTION getTratamientoID(nombre varchar(100)) RETURNS INT DETERMINISTIC
BEGIN

	RETURN(
    SELECT idTratamiento FROM Tratamiento
    WHERE Tratamiento.Nombre = nombre
    );
	
END $$

DELIMITER ;


-- ******************************************************************
-- Funcion y Procedure para cargar datos de victimas en el modelo
-- ******************************************************************
DELETE FROM Victima WHERE idVictima>0;
ALTER TABLE Victima AUTO_INCREMENT = 1;

DELIMITER $$

CREATE FUNCTION getVictimas(nombres varchar(50),apellidos varchar(50)) RETURNS BOOLEAN DETERMINISTIC
BEGIN

	RETURN CONCAT(nombres,apellidos) NOT IN (SELECT CONCAT(Victima.Nombres,Victima.Apellidos) FROM Victima) ;
	
END $$

CREATE PROCEDURE loadVictimas()
BEGIN

	INSERT INTO Victima(Nombres,Apellidos,Direccion,FechaSospecha,FechaConfirmacion,FechaMuerte,Estado)
    SELECT 
	CSVTable.NOMBRE_VICTIMA,
	CSVTable.APELLIDO_VICTIMA,
	CSVTable.DIRECCION_VICTIMA,
	CSVTable.FECHA_PRIMERA_SOSPECHA,
	CSVTable.FECHA_CONFIRMACION,
	CSVTable.FECHA_MUERTE,
	CSVTable.ESTADO_VICTIMA
	FROM
	CSVTable WHERE CSVTable.NOMBRE_VICTIMA != '' AND getVictimas(CSVTable.NOMBRE_VICTIMA,CSVTable.APELLIDO_VICTIMA);

END $$

DELIMITER ;

CALL loadVictimas();
SELECT * FROM Victima;

-- ******************************************************************
-- Funcion y Procedure para cargar datos de hospital en el modelo
-- ******************************************************************
DELETE FROM Hospital WHERE idHospital>0;
ALTER TABLE Hospital AUTO_INCREMENT = 1;

DELIMITER $$

CREATE FUNCTION getHospitales(nombre varchar(100)) RETURNS BOOLEAN DETERMINISTIC
BEGIN

	RETURN  nombre NOT IN (SELECT Hospital.Nombre FROM Hospital);
	
END $$

CREATE PROCEDURE loadHospitales()
BEGIN

	INSERT INTO Hospital(Nombre,Direccion)
    SELECT 
    CSVTable.NOMBRE_HOSPITAL,
	CSVTable.DIRECCION_HOSPITAL
	FROM
	CSVTable WHERE CSVTable.NOMBRE_HOSPITAL != '' AND getHospitales(CSVTable.NOMBRE_HOSPITAL);

END $$

DELIMITER ;

CALL loadHospitales();
SELECT * FROM Hospital;

-- ******************************************************************
-- Funcion y Procedure para cargar datos de Asociado en el modelo
-- ******************************************************************
DELETE FROM Asociado WHERE idAsociado>0;
ALTER TABLE Asociado AUTO_INCREMENT = 1;

DELIMITER $$

CREATE FUNCTION getAsociados(nombres varchar(50),apellidos varchar(50)) RETURNS BOOLEAN DETERMINISTIC
BEGIN

	RETURN  CONCAT(nombres,apellidos) NOT IN (SELECT CONCAT(Asociado.Nombres,Asociado.Apellidos) FROM Asociado) ;
	
END $$

CREATE PROCEDURE loadAsociados()
BEGIN

	INSERT INTO Asociado(Nombres,Apellidos)
    SELECT 
    CSVTable.NOMBRE_ASOCIADO,
	CSVTable.APELLIDO_ASOCIADO
	FROM
	CSVTable WHERE CSVTable.NOMBRE_ASOCIADO != '' AND getAsociados(CSVTable.NOMBRE_ASOCIADO,CSVTable.APELLIDO_ASOCIADO);

END $$

DELIMITER ;

CALL loadAsociados();
SELECT * FROM Asociado;

-- ******************************************************************
-- Funcion y Procedure para cargar datos de Victima-Asociado en el modelo
-- ******************************************************************
DELETE FROM VictimaAsociado WHERE idVictimaAsociado>0;
ALTER TABLE VictimaAsociado AUTO_INCREMENT = 1;

DELIMITER $$

CREATE FUNCTION getVictimaAsociado(victimaID int, asociadoID int ) RETURNS BOOLEAN DETERMINISTIC
BEGIN

	RETURN (victimaID,asociadoID) NOT IN (SELECT VictimaAsociado.idVictima,VictimaAsociado.idAsociado FROM VictimaAsociado) ;
	
END $$

CREATE PROCEDURE loadVictimaAsociados()
BEGIN

	INSERT INTO VictimaAsociado(FechaConocio,idVictima,idAsociado)
	SELECT 
	CSVTable.FECHA_CONOCIO,
    getVictimaID(CSVTable.NOMBRE_VICTIMA,CSVTable.APELLIDO_VICTIMA),
    getAsociadoID(CSVTable.NOMBRE_ASOCIADO,CSVTable.APELLIDO_ASOCIADO)
	FROM CSVTable
    WHERE 
    CSVTable.FECHA_CONOCIO != '0000-00-00 00:00:00' 
    AND getVictimaAsociado(getVictimaID(CSVTable.NOMBRE_VICTIMA,CSVTable.APELLIDO_VICTIMA),getAsociadoID(CSVTable.NOMBRE_ASOCIADO,CSVTable.APELLIDO_ASOCIADO));

END $$

DELIMITER ;

CALL loadVictimaAsociados();
SELECT * FROM VictimaAsociado;

-- ******************************************************************
-- Funcion y Procedure para cargar datos de Registro en el modelo
-- ******************************************************************
DELETE FROM Registro WHERE idRegistro>0;
ALTER TABLE Registro AUTO_INCREMENT = 1;

DELIMITER $$

CREATE FUNCTION getRegistro(hospitalID int, victimaID int ) RETURNS BOOLEAN DETERMINISTIC
BEGIN

	RETURN (hospitalID,victimaID) NOT IN (SELECT Registro.idHospital,Registro.idVictima FROM Registro) ;
	
END $$

CREATE PROCEDURE loadRegistro()
BEGIN

	INSERT INTO Registro(idHospital,idVictima)
	SELECT 
	getHospitalID(CSVTable.NOMBRE_HOSPITAL),
    getVictimaID(CSVTable.NOMBRE_VICTIMA,CSVTable.APELLIDO_VICTIMA)
	FROM CSVTable
    WHERE 
    CSVTable.NOMBRE_HOSPITAL!= '' 
    AND getRegistro(getHospitalID(CSVTable.NOMBRE_HOSPITAL),getVictimaID(CSVTable.NOMBRE_VICTIMA,CSVTable.APELLIDO_VICTIMA));

END $$

DELIMITER ;

CALL loadRegistro();
SELECT * FROM Registro;

-- ******************************************************************
-- Funcion y Procedure para cargar datos de Ubicacion en el modelo
-- ******************************************************************
DELETE FROM Ubicacion WHERE idUbicacion>0;
ALTER TABLE Ubicacion AUTO_INCREMENT = 1;

DELIMITER $$

CREATE FUNCTION getUbicacion(victimaID int, fechaLlegada datetime, fechaRetiro datetime) RETURNS BOOLEAN DETERMINISTIC
BEGIN

	RETURN (victimaID,fechaLlegada,fechaRetiro) NOT IN (SELECT Ubicacion.idVictima,Ubicacion.FechaLlegada,Ubicacion.FechaRetiro FROM Ubicacion)	;
	
END $$

CREATE PROCEDURE loadUbicacion()
BEGIN

	INSERT INTO Ubicacion(idVictima,FechaLlegada,FechaRetiro,Direccion)
	SELECT 
    getVictimaID(CSVTable.NOMBRE_VICTIMA,CSVTable.APELLIDO_VICTIMA),
    CSVTable.FECHA_LLEGADA,
    CSVTable.FECHA_RETIRO,
    CSVTable.UBICACION_VICTIMA
	FROM CSVTable
    WHERE 
    CSVTable.UBICACION_VICTIMA!= '' 
    AND getUbicacion(getVictimaID(CSVTable.NOMBRE_VICTIMA,CSVTable.APELLIDO_VICTIMA),CSVTable.FECHA_LLEGADA,CSVTable.FECHA_RETIRO);

END $$

DELIMITER ;

CALL loadUbicacion();
SELECT * FROM Ubicacion;

-- ******************************************************************
-- Funcion y Procedure para cargar datos de Contacto en el modelo
-- ******************************************************************
DELETE FROM Contacto WHERE idContacto>0;
ALTER TABLE Contacto AUTO_INCREMENT = 1;

DELIMITER $$

CREATE FUNCTION getContacto(victimaAsociadoID int, fechaInicio datetime, fechaFin datetime) RETURNS BOOLEAN DETERMINISTIC
BEGIN

	RETURN (victimaAsociadoID,fechaInicio,fechaFin) NOT IN (SELECT Contacto.idVictimaAsociado,Contacto.FechaInicio,Contacto.FechaFin FROM Contacto)	;
	
END $$

CREATE PROCEDURE loadContacto()
BEGIN

	INSERT INTO Contacto(idVictimaAsociado,Tipo,FechaInicio,FechaFin)
	SELECT 
    getVictimaAsociadoID(getVictimaID(CSVTable.NOMBRE_VICTIMA,CSVTable.APELLIDO_VICTIMA),getAsociadoID(CSVTable.NOMBRE_ASOCIADO,CSVTable.APELLIDO_ASOCIADO)),
    CSVTable.CONTACTO_FISICO,
    CSVTable.FECHA_INICIO_CONTACTO,
    CSVTable.FECHA_FIN_CONTACTO
	FROM CSVTable
    WHERE 
    CSVTable.CONTACTO_FISICO!= '' 
    AND getContacto(getVictimaAsociadoID(getVictimaID(CSVTable.NOMBRE_VICTIMA,CSVTable.APELLIDO_VICTIMA),getAsociadoID(CSVTable.NOMBRE_ASOCIADO,CSVTable.APELLIDO_ASOCIADO)),CSVTable.FECHA_INICIO_CONTACTO,CSVTable.FECHA_FIN_CONTACTO);

END $$

DELIMITER ;

CALL loadContacto();
SELECT * FROM Contacto;

-- ******************************************************************
-- Funcion y Procedure para cargar datos de Tratamiento en el modelo
-- ******************************************************************
DELETE FROM Tratamiento WHERE idTratamiento>0;
ALTER TABLE Tratamiento AUTO_INCREMENT = 1;

DELIMITER $$

CREATE FUNCTION getTratamiento(nombre varchar(100)) RETURNS BOOLEAN DETERMINISTIC
BEGIN

	RETURN (nombre) NOT IN (SELECT Tratamiento.Nombre FROM Tratamiento)	;
	
END $$

CREATE PROCEDURE loadTratamiento()
BEGIN

	INSERT INTO Tratamiento(Nombre,Efectividad)
	SELECT 
    CSVTable.TRATAMIENTO,
    CSVTable.EFECTIVIDAD
	FROM CSVTable
    WHERE 
    CSVTable.Tratamiento!= '' 
    AND getTratamiento(CSVTable.TRATAMIENTO);

END $$

DELIMITER ;

CALL loadTratamiento();
SELECT * FROM Tratamiento;

-- ******************************************************************
-- Funcion y Procedure para cargar datos de PersonaTratamiento en el modelo
-- ******************************************************************
DELETE FROM PersonaTratamiento WHERE idPersonaTratamiento>0;
ALTER TABLE PersonaTratamiento AUTO_INCREMENT = 1;

DELIMITER $$

CREATE FUNCTION getPersonaTratamiento(registroID int,tratamientoID int,fechaInicio datetime,fechaFin datetime) RETURNS BOOLEAN DETERMINISTIC
BEGIN

	RETURN (registroID,tratamientoID,fechaInicio,fechaFin) NOT IN (SELECT PersonaTratamiento.idRegistro,PersonaTratamiento.idTratamiento,PersonaTratamiento.FechaInicio,PersonaTratamiento.FechaFin FROM PersonaTratamiento)	;
	
END $$

CREATE PROCEDURE loadPersonaTratamiento()
BEGIN

	INSERT INTO PersonaTratamiento(idRegistro,idTratamiento,FechaInicio,FechaFin,Efectividad)
	SELECT 
    getRegistroID(getHospitalID(CSVTable.NOMBRE_HOSPITAL),getVictimaID(CSVTable.NOMBRE_VICTIMA,CSVTable.APELLIDO_VICTIMA)),
    getTratamientoID(CSVTable.TRATAMIENTO),
    CSVTable.FECHA_INICIO_TRATAMIENTO,
    CSVTable.FECHA_FIN_TRATAMIENTO,
    CSVTable.EFECTIVIDAD_EN_VICTIMA
	FROM CSVTable
    WHERE 
    CSVTable.Tratamiento!= '' 
    AND 
    getPersonaTratamiento(
    getRegistro(getHospitalID(CSVTable.NOMBRE_HOSPITAL),getVictimaID(CSVTable.NOMBRE_VICTIMA,CSVTable.APELLIDO_VICTIMA)),
    getTratamientoID(CSVTable.TRATAMIENTO),
    CSVTable.FECHA_INICIO_TRATAMIENTO,
    CSVTable.FECHA_FIN_TRATAMIENTO
    );

END $$

DELIMITER ;

CALL loadPersonaTratamiento();
SELECT * FROM PersonaTratamiento;


-- ******************************************************************
-- Drop de Funciones 
-- ******************************************************************
DROP FUNCTION IF EXISTS getVictimaID;
DROP FUNCTION IF EXISTS getAsociadoID;
DROP FUNCTION IF EXISTS getHospitalID;
DROP FUNCTION IF EXISTS getRegistroID;
DROP FUNCTION IF EXISTS getVictimaAsociadoID;
DROP FUNCTION IF EXISTS getTratamientoID;

-- ******************************************************************
-- Drop de Procedimientos de Carga 
-- ******************************************************************
DROP PROCEDURE IF EXISTS loadVictimas;
DROP PROCEDURE IF EXISTS loadHospitales;
DROP PROCEDURE IF EXISTS loadAsociados;
DROP PROCEDURE IF EXISTS loadVictimaAsociados;
DROP PROCEDURE IF EXISTS loadRegistro;
DROP PROCEDURE IF EXISTS loadUbicacion;
DROP PROCEDURE IF EXISTS loadContacto;
DROP PROCEDURE IF EXISTS loadTratamiento;
DROP PROCEDURE IF EXISTS loadPersonaTratamiento;
-- ******************************************************************
-- Drop de Funciones de Carga
-- ******************************************************************
DROP FUNCTION IF EXISTS getVictimas;
DROP FUNCTION IF EXISTS getHospitales;
DROP FUNCTION IF EXISTS getAsociados;
DROP FUNCTION IF EXISTS getVictimaAsociado;
DROP FUNCTION IF EXISTS getRegistro;
DROP FUNCTION IF EXISTS getUbicacion;
DROP FUNCTION IF EXISTS getContacto;
DROP FUNCTION IF EXISTS getTratamiento;
DROP FUNCTION IF EXISTS getPersonaTratamiento;







