
-- ******************************************************************
-- *           Correr solo una vez en MySQL Workbench               *
-- ******************************************************************




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

-- ******************************************************************
-- Funcion y Procedure para cargar datos de victimas en el modelo
-- ******************************************************************

CREATE FUNCTION getVictimas(nombres varchar(50),apellidos varchar(50)) RETURNS BOOLEAN DETERMINISTIC
BEGIN

	RETURN (CONCAT(nombres,apellidos) NOT IN (SELECT CONCAT(Victima.Nombres,Victima.Apellidos) FROM Victima));
	
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

-- ******************************************************************
-- Funcion y Procedure para cargar datos de hospital en el modelo
-- ******************************************************************

CREATE FUNCTION getHospitales(nombre varchar(100)) RETURNS BOOLEAN DETERMINISTIC
BEGIN

	RETURN  (nombre NOT IN (SELECT Hospital.Nombre FROM Hospital));
	
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

-- ******************************************************************
-- Funcion y Procedure para cargar datos de Asociado en el modelo
-- ******************************************************************

CREATE FUNCTION getAsociados(nombres varchar(50),apellidos varchar(50)) RETURNS BOOLEAN DETERMINISTIC
BEGIN

	RETURN  (CONCAT(nombres,apellidos) NOT IN (SELECT CONCAT(Asociado.Nombres,Asociado.Apellidos) FROM Asociado));
	
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

-- ******************************************************************
-- Funcion y Procedure para cargar datos de Victima-Asociado en el modelo
-- ******************************************************************

CREATE FUNCTION getVictimaAsociado(victimaID int, asociadoID int ) RETURNS BOOLEAN DETERMINISTIC
BEGIN

	RETURN ((victimaID,asociadoID) NOT IN (SELECT VictimaAsociado.idVictima,VictimaAsociado.idAsociado FROM VictimaAsociado));
	
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

-- ******************************************************************
-- Funcion y Procedure para cargar datos de Registro en el modelo
-- ******************************************************************

CREATE FUNCTION getRegistro(hospitalID int, victimaID int ) RETURNS BOOLEAN DETERMINISTIC
BEGIN

	RETURN ((hospitalID,victimaID) NOT IN (SELECT Registro.idHospital,Registro.idVictima FROM Registro));
	
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

-- ******************************************************************
-- Funcion y Procedure para cargar datos de Ubicacion en el modelo
-- ******************************************************************

CREATE FUNCTION getUbicacion(victimaID int, fechaLlegada datetime, fechaRetiro datetime) RETURNS BOOLEAN DETERMINISTIC
BEGIN

	RETURN ((victimaID,fechaLlegada,fechaRetiro) NOT IN (SELECT Ubicacion.idVictima,Ubicacion.FechaLlegada,Ubicacion.FechaRetiro FROM Ubicacion));
	
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

-- ******************************************************************
-- Funcion y Procedure para cargar datos de Contacto en el modelo
-- ******************************************************************

CREATE FUNCTION getContacto(victimaAsociadoID int, fechaInicio datetime, fechaFin datetime) RETURNS BOOLEAN DETERMINISTIC
BEGIN

	RETURN ((victimaAsociadoID,fechaInicio,fechaFin) NOT IN (SELECT Contacto.idVictimaAsociado,Contacto.FechaInicio,Contacto.FechaFin FROM Contacto));
	
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

-- ******************************************************************
-- Funcion y Procedure para cargar datos de Tratamiento en el modelo
-- ******************************************************************

CREATE FUNCTION getTratamiento(nombre varchar(100)) RETURNS BOOLEAN DETERMINISTIC
BEGIN

	RETURN ((nombre) NOT IN (SELECT Tratamiento.Nombre FROM Tratamiento));
	
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

-- ******************************************************************
-- Funcion y Procedure para cargar datos de PersonaTratamiento en el modelo
-- ******************************************************************

CREATE FUNCTION getPersonaTratamiento(registroID int,tratamientoID int,fechaInicio datetime,fechaFin datetime) RETURNS BOOLEAN DETERMINISTIC
BEGIN

	RETURN (
    (registroID,tratamientoID,fechaInicio,fechaFin) NOT IN (SELECT PersonaTratamiento.idRegistro,PersonaTratamiento.idTratamiento,PersonaTratamiento.FechaInicio,PersonaTratamiento.FechaFin FROM PersonaTratamiento)
    );
	
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
    getRegistroID(getHospitalID(CSVTable.NOMBRE_HOSPITAL),getVictimaID(CSVTable.NOMBRE_VICTIMA,CSVTable.APELLIDO_VICTIMA)),
    getTratamientoID(CSVTable.TRATAMIENTO),
    CSVTable.FECHA_INICIO_TRATAMIENTO,
    CSVTable.FECHA_FIN_TRATAMIENTO
    );

END $$

-- ******************************************************************
-- Funcion y Procedure para Consulta 7
-- ******************************************************************

CREATE FUNCTION getNumAllegados(victimaID int) RETURNS INT DETERMINISTIC
BEGIN

	RETURN (
		SELECT COUNT(*) FROM Asociado
        INNER JOIN VictimaAsociado ON Asociado.idAsociado = VictimaAsociado.idAsociado
        INNER JOIN Victima ON VictimaAsociado.idVictima = Victima.idVictima
        WHERE Victima.idVictima = victimaID
    );
		
END $$

CREATE FUNCTION getNumTratamientos(victimaID int) RETURNS INT DETERMINISTIC
BEGIN

	RETURN (
		SELECT COUNT(*) FROM Tratamiento
        INNER JOIN PersonaTratamiento ON Tratamiento.idTratamiento = PersonaTratamiento.idTratamiento
        INNER JOIN Registro ON PersonaTratamiento.idRegistro = Registro.idRegistro
        INNER JOIN Victima ON Registro.idVictima = Victima.idVictima
        WHERE Victima.idVictima = victimaID
    );
		
END $$

-- ******************************************************************
-- Funcion para Consulta 9
-- ******************************************************************

CREATE FUNCTION getTotalFallecidos() RETURNS INT DETERMINISTIC
BEGIN

	RETURN (
		SELECT SUM(Fallecidos) FROM (
			SELECT COUNT(*) AS Fallecidos FROM Registro 
			INNER JOIN Victima ON Victima.idVictima = Registro.idVictima 
			INNER JOIN Hospital ON Hospital.idHospital = Registro.idHospital
			WHERE Victima.Estado = 'Muerte' 
			GROUP BY Registro.idHospital
        ) AS A
    );
		
END$$

-- ******************************************************************
-- Funcion para Consulta 10
-- ******************************************************************

CREATE FUNCTION getContactos(nombre varchar(100)) RETURNS BOOLEAN DETERMINISTIC
BEGIN
        RETURN (
			(nombre) NOT IN (SELECT Nombre_Hospital FROm Temp1)
        );
END $$