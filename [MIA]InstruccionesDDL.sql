USE MIA_Practica;
CALL dropModel();

CREATE TABLE Hospital( 
    idHospital INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100),
    Direccion VARCHAR(250)
);

CREATE TABLE Victima(
    idVictima INT NOT NULL AUTO_INCREMENT PRIMARY KEY,                        
    Nombres VARCHAR(50),
    Apellidos VARCHAR(50),
    Direccion VARCHAR(250),
    FechaSospecha DATETIME,
    FechaConfirmacion DATETIME,
    FechaMuerte DATETIME,
    Estado VARCHAR(50)
);

CREATE TABLE Asociado(
    idAsociado INT NOT NULL AUTO_INCREMENT PRIMARY KEY,                        
    Nombres VARCHAR(50),
    Apellidos VARCHAR(50)
);

CREATE TABLE Registro(

    idRegistro INT NOT NULL AUTO_INCREMENT PRIMARY KEY,   
    
	idHospital int NOT NULL,
    INDEX Registro_idHospital_FK(idHospital),
    FOREIGN KEY (idHospital) REFERENCES Hospital(idHospital) ON DELETE CASCADE,
	
    idVictima int NOT NULL,
    INDEX Registro_idVictima_FK(idVictima),
    FOREIGN KEY (idVictima) REFERENCES Victima(idVictima) ON DELETE CASCADE

);
                        
CREATE TABLE VictimaAsociado(

    idVictimaAsociado INT NOT NULL AUTO_INCREMENT PRIMARY KEY,                        
    FechaConocio DATETIME,
	
    idVictima int NOT NULL,
    INDEX VictimaAsociado_idVictima_FK(idVictima),
    FOREIGN KEY (idVictima) REFERENCES Victima(idVictima) ON DELETE CASCADE,
	
    idAsociado int NOT NULL,
    INDEX VictimaAsociado_idAsociado_FK(idAsociado),
    FOREIGN KEY (idAsociado) REFERENCES Asociado(idAsociado) ON DELETE CASCADE

);

CREATE TABLE Ubicacion(

    idUbicacion INT NOT NULL AUTO_INCREMENT PRIMARY KEY,                        
    FechaLlegada DATETIME,
    FechaRetiro DATETIME,
    Direccion varchar(250),
	
    idVictima int NOT NULL,
    INDEX Ubicacion_idVictima_FK(idVictima),
    FOREIGN KEY (idVictima) REFERENCES Victima(idVictima) ON DELETE CASCADE

);

CREATE TABLE Contacto(

    idContacto INT NOT NULL AUTO_INCREMENT PRIMARY KEY,                        
    FechaInicio DATETIME,
    FechaFin DATETIME,
    Tipo varchar(25),
	
    idVictimaAsociado int NOT NULL,
    INDEX Contacto_idVictimaAsociado_FK(idVictimaAsociado),
    FOREIGN KEY (idVictimaAsociado) REFERENCES VictimaAsociado(idVictimaAsociado) ON DELETE CASCADE

);

CREATE TABLE Tratamiento(

    idTratamiento INT NOT NULL AUTO_INCREMENT PRIMARY KEY,                        
    Nombre varchar(100),
    Efectividad int
    
);

CREATE TABLE PersonaTratamiento(

    idPersonaTratamiento INT NOT NULL AUTO_INCREMENT PRIMARY KEY,                        
    FechaInicio DATETIME,
    FechaFin DATETIME,
    Efectividad int,
	
    idRegistro int NOT NULL,
    INDEX PersonaTratamiento_idRegistro_FK(idRegistro),
    FOREIGN KEY (idRegistro) REFERENCES Registro(idRegistro) ON DELETE CASCADE,
	
    idTratamiento int NOT NULL,
    INDEX PersonaTratamiento_idTratamiento_FK(idTratamiento),
    FOREIGN KEY (idTratamiento) REFERENCES Tratamiento(idTratamiento) ON DELETE CASCADE

);

-- ******************************************************************
-- Se cargan Victimas
-- ******************************************************************
DELETE FROM Victima WHERE idVictima>0;
ALTER TABLE Victima AUTO_INCREMENT = 1;
CALL loadVictimas();

-- ******************************************************************
-- Se cargan Hospitales
-- ******************************************************************
DELETE FROM Hospital WHERE idHospital>0;
ALTER TABLE Hospital AUTO_INCREMENT = 1;
CALL loadHospitales();

-- ******************************************************************
-- Se cargan Asociados
-- ******************************************************************
DELETE FROM Asociado WHERE idAsociado>0;
ALTER TABLE Asociado AUTO_INCREMENT = 1;
CALL loadAsociados();

-- ******************************************************************
-- Se cargan VictimaAsociados
-- ******************************************************************
DELETE FROM VictimaAsociado WHERE idVictimaAsociado>0;
ALTER TABLE VictimaAsociado AUTO_INCREMENT = 1;
CALL loadVictimaAsociados();

-- ******************************************************************
-- Funcion y Procedure para cargar datos de Registro en el modelo
-- ******************************************************************
DELETE FROM Registro WHERE idRegistro>0;
ALTER TABLE Registro AUTO_INCREMENT = 1;
CALL loadRegistro();

-- ******************************************************************
-- Se cargan Ubicaciones
-- ******************************************************************
DELETE FROM Ubicacion WHERE idUbicacion>0;
ALTER TABLE Ubicacion AUTO_INCREMENT = 1;
CALL loadUbicacion();

-- ******************************************************************
-- Se cargan Contactos
-- ******************************************************************
DELETE FROM Contacto WHERE idContacto>0;
ALTER TABLE Contacto AUTO_INCREMENT = 1;
CALL loadContacto();

-- ******************************************************************
-- Se cargan tratamientos
-- ******************************************************************
DELETE FROM Tratamiento WHERE idTratamiento>0;
ALTER TABLE Tratamiento AUTO_INCREMENT = 1;
CALL loadTratamiento();

-- ******************************************************************
-- Se cargan PersonaTratamientos
-- ******************************************************************
DELETE FROM PersonaTratamiento WHERE idPersonaTratamiento>0;
ALTER TABLE PersonaTratamiento AUTO_INCREMENT = 1;
CALL loadPersonaTratamiento();
