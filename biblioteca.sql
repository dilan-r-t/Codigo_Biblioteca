-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 13-08-2024 a las 22:19:10
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: biblioteca
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=root@localhost PROCEDURE ActualizarTelefonoYDireccion (IN p_soc_numero INT, IN p_soc_direccion VARCHAR(255), IN p_soc_telefono VARCHAR(20))   BEGIN
    UPDATE tbl_socio
    SET
        soc_direccion = p_soc_direccion,
        soc_telefono = p_soc_telefono
    WHERE soc_numero = p_soc_numero;
END$$

CREATE DEFINER=root@localhost PROCEDURE BuscarLibroPorNombre (IN p_lib_titulo VARCHAR(255))   BEGIN
    SELECT 
        lib_isbn,
        lib_titulo,
        lib_numeroPaginas,
        lib_genero,
        lib_diasPrestamo
    FROM tbl_libro
    WHERE lib_titulo LIKE CONCAT('%', p_lib_titulo, '%');
END$$

CREATE DEFINER=root@localhost PROCEDURE EliminarLibro (IN p_lib_isbn BIGINT)   BEGIN
   
    IF NOT EXISTS (SELECT 1 FROM tbl_prestamo WHERE lib_copiaISBN = p_lib_isbn) THEN
    
        DELETE FROM tbl_libro WHERE lib_isbn = p_lib_isbn;
    ELSE
        
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar el libro porque tiene dependencias en tbl_prestamo.';
    END IF;
END$$

CREATE DEFINER=root@localhost PROCEDURE get_listaAutores ()   SELECT aut_codigo,aut_apellido
FROM tbl_autor
ORDER BY aut_apellido DESC$$

CREATE DEFINER=root@localhost PROCEDURE get_tipoAutor (variable VARCHAR(20))   SELECT aut_apellido as 'Autor', tipoAutor
FROM tbl_autor
INNER JOIN tbl_tipoautores
ON aut_codigo=copiaAutor
WHERE tipoAutor=variable$$

CREATE DEFINER=root@localhost PROCEDURE InsertarSocio (IN p_soc_numero INT, IN p_soc_nombre VARCHAR(100), IN p_soc_apellido VARCHAR(100), IN p_soc_direccion VARCHAR(255), IN p_soc_telefono VARCHAR(20))   BEGIN
    INSERT INTO tbl_socio (
        soc_numero,
        soc_nombre,
        soc_apellido,
        soc_direccion,
        soc_telefono
    ) VALUES (
        p_soc_numero,
        p_soc_nombre,
        p_soc_apellido,
        p_soc_direccion,
        p_soc_telefono
    );
END$$

CREATE DEFINER=root@localhost PROCEDURE insert_libro (c1_isbn BIGINT(20), c2_titulo VARCHAR(255), c3_genero VARCHAR(20), c4_paginas INT(11), c5diaspres TINYINT(4))   INSERT INTO
tbl_libro(lib_isbn,lib_titulo,lib_genero,lib_numeroPaginas,lib_diasPrestamo)
VALUES (c1_isbn,c2_titulo,c3_genero, c4_paginas,c5diaspres)$$

CREATE DEFINER=root@localhost PROCEDURE ListarLibrosEnPrestamoConAutor ()   BEGIN
    SELECT
        l.lib_isbn,
        l.lib_titulo,
        s.soc_numero,
        s.soc_nombre,
        s.soc_apellido,
        a.aut_apellido,
        p.pres_fechaPrestamo,
        p.pres_fechaDevolucion
    FROM tbl_prestamo p
    INNER JOIN tbl_libro l ON p.lib_copiaISBN = l.lib_isbn
    INNER JOIN tbl_socio s ON p.soc_copiaNumero = s.soc_numero
    INNER JOIN tbl_tipoautores ta ON l.lib_isbn = ta.copiaISBN
    INNER JOIN tbl_autor a ON ta.copiaAutor = a.aut_codigo;
END$$

CREATE DEFINER=root@localhost PROCEDURE ObtenerSociosConPrestamos ()   BEGIN
    SELECT s.soc_numero, s.soc_nombre, p.pres_id, p.pres_fechaPrestamo
    FROM tbl_socio s
    LEFT JOIN tbl_prestamo p ON s.soc_numero = p.soc_copiaNumero;
END$$

--
-- Funciones
--
DELIMITER $$

CREATE FUNCTION ContarSocios () RETURNS INT(11)  BEGIN
    DECLARE total_socios INT;
    SELECT COUNT(*) INTO total_socios FROM tbl_socio;
    RETURN total_socios;
END$$
------
DELIMITER $$

CREATE DEFINER=root@localhost FUNCTION DiasEnPrestamo (p_lib_isbn BIGINT) RETURNS INT(11)  BEGIN
    DECLARE total_dias INT DEFAULT 0;

   
    SELECT COALESCE(SUM(DATEDIFF(pres_fechaDevolucion, pres_fechaPrestamo)), 0)
    INTO total_dias
    FROM tbl_prestamo
    WHERE lib_copiaISBN = p_lib_isbn AND pres_fechaDevolucion IS NOT NULL;


    RETURN total_dias;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla audi_autor
--

CREATE TABLE audi_autor (
  audi_accion varchar(50) DEFAULT NULL,
  audi_fechaModificacion datetime DEFAULT NULL,
  audi_usuario varchar(255) DEFAULT NULL,
  aut_codigo int(11) DEFAULT NULL,
  aut_apellido varchar(255) DEFAULT NULL,
  aut_muerte date DEFAULT NULL,
  aut_nacimiento date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla audi_socio
--

CREATE TABLE audi_socio (
  id_audi int(10) NOT NULL,
  socNumero_audi int(11) DEFAULT NULL,
  socNombre_anterior varchar(45) DEFAULT NULL,
  socApellido_anterior varchar(45) DEFAULT NULL,
  socDireccion_anterior varchar(255) DEFAULT NULL,
  socTelefono_anterior varchar(10) DEFAULT NULL,
  socNombre_nuevo varchar(45) DEFAULT NULL,
  socApellido_nuevo varchar(45) DEFAULT NULL,
  socDireccion_nuevo varchar(255) DEFAULT NULL,
  socTelefono_nuevo varchar(10) DEFAULT NULL,
  audi_fechaModificacion datetime DEFAULT NULL,
  audi_usuario varchar(10) DEFAULT NULL,
  audi_accion varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla audi_socio
--

INSERT INTO audi_socio (id_audi, socNumero_audi, socNombre_anterior, socApellido_anterior, socDireccion_anterior, socTelefono_anterior, socNombre_nuevo, socApellido_nuevo, socDireccion_nuevo, socTelefono_nuevo, audi_fechaModificacion, audi_usuario, audi_accion) VALUES
(1, 13, 'Juan', 'Pérez', 'Calle Falsa 123', '555-1234', 'Juan', 'Pérez', 'Calle 72 # 2', '2928088', '2024-07-31 09:53:32', 'root@local', 'Actualización'),
(2, 0, NULL, NULL, NULL, NULL, 'Camila', 'Rodriguez', 'Narnia con calle 6', '4415574578', '2024-08-01 07:39:33', 'root@local', 'INSERT'),
(3, 0, 'Camila', 'Rodriguez', 'Narnia con calle 6', '4415574578', NULL, NULL, NULL, NULL, '2024-08-01 07:40:02', 'root@local', 'Registro eliminado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla tbl_auditoria_libro
--

CREATE TABLE tbl_auditoria_libro (
  audit_id int(11) NOT NULL,
  lib_isbn varchar(13) DEFAULT NULL,
  lib_titulo varchar(255) DEFAULT NULL,
  operacion varchar(50) DEFAULT NULL,
  usuario varchar(255) DEFAULT NULL,
  fecha timestamp NOT NULL DEFAULT current_timestamp(),
  old_lib_titulo varchar(255) DEFAULT NULL,
  old_lib_autor varchar(255) DEFAULT NULL,
  old_lib_numpaginas int(11) DEFAULT NULL,
  old_lib_editorial varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla tbl_autor
--

CREATE TABLE tbl_autor (
  aut_codigo int(11) NOT NULL,
  aut_apellido varchar(45) NOT NULL,
  aut_nacimiento date NOT NULL,
  aut_muerte date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla tbl_autor
--

INSERT INTO tbl_autor (aut_codigo, aut_apellido, aut_nacimiento, aut_muerte) VALUES
(0, 'aut_apellido', '0000-00-00', '2021-12-09'),
(98, 'Smith', '1974-12-21', '2018-07-21'),
(123, 'Taylor', '1980-04-15', '0000-00-00'),
(234, 'Medina', '1977-06-21', '2005-09-12'),
(345, 'Wilson', '1975-08-29', '0000-00-00'),
(432, 'Miller', '1981-10-26', '0000-00-00'),
(456, 'García', '1978-09-27', '2021-12-09'),
(567, 'Davis', '1983-03-04', '2010-03-28'),
(678, 'Silva', '1986-02-02', '0000-00-00'),
(765, 'López', '1976-07-08', '2024-07-24'),
(789, 'Rodríguez', '1985-12-10', '0000-00-00'),
(890, 'Brown', '1982-11-17', '0000-00-00'),
(901, 'Soto', '1979-05-13', '2015-11-05');

--
-- Disparadores tbl_autor
--
DELIMITER $$
CREATE TRIGGER trg_audit_delete_autor AFTER DELETE ON tbl_autor FOR EACH ROW BEGIN
    INSERT INTO audi_autor (
        audi_accion, 
        audi_fechaModificacion, 
        audi_usuario, 
        aut_codigo, 
        aut_apellido, 
        aut_muerte, 
        aut_nacimiento
    ) VALUES (
        'DELETE', 
        NOW(), 
        USER(),  -- Aquí puedes reemplazar USER() con el nombre de usuario si se requiere algo específico
        OLD.aut_codigo,
        OLD.aut_apellido,
        OLD.aut_muerte,
        OLD.aut_nacimiento
    );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla tbl_libro
--

CREATE TABLE tbl_libro (
  lib_isbn bigint(20) NOT NULL,
  lib_titulo varchar(45) NOT NULL,
  lib_genero varchar(45) NOT NULL,
  lib_numeroPaginas int(11) NOT NULL,
  lib_diasPrestamo tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla tbl_libro
--

INSERT INTO tbl_libro (lib_isbn, lib_titulo, lib_genero, lib_numeroPaginas, lib_diasPrestamo) VALUES
(0, 'lib_titulo', 'lib_genero', 0, 0),
(1234567890, 'El Sueño de los Susurros', 'novela', 275, 7),
(1357924680, 'El Jardín de las Mariposas Perdidas', 'novela', 536, 7),
(2468135790, 'La Melodía de la Oscuridad', 'romance', 189, 7),
(2718281828, 'El Bosque de los Suspiros', 'novela', 387, 2),
(3141592653, 'El Secreto de las Estrellas Olvidadas', 'Misterio', 203, 7),
(5555555555, 'La Última Llave del Destino', 'cuento', 503, 7),
(7777777777, 'El Misterio de la Luna Plateada', 'Misterio', 422, 7),
(8642097531, 'El Reloj de Arena Infinito', 'novela', 321, 7),
(8888888888, 'La Ciudad de los Susurros', 'Misterio', 274, 1),
(9517530862, 'Las Crónicas del Eco Silencioso', 'fantasía', 448, 7),
(9876543210, 'El Laberinto de los Recuerdos', 'cuento', 412, 7),
(9999999999, 'El Enigma de los Espejos Rotos', 'romance', 156, 7),
(9788426721006, 'sql', 'ingenieria', 384, 15);

--
-- Disparadores tbl_libro
--
DELIMITER $$
CREATE TRIGGER trg_audit_update_libro BEFORE UPDATE ON tbl_libro FOR EACH ROW BEGIN
    INSERT INTO audi_libro (
        audi_accion,
        audi_fechaModificacion,
        audi_usuario,
        lib_isbn,
        lib_titulo_anterior,
        lib_titulo_nuevo,
        lib_genero_anterior,
        lib_genero_nuevo,
        lib_numeroPaginas_anterior,
        lib_numeroPaginas_nuevo,
        lib_diasPrestamo_anterior,
        lib_diasPrestamo_nuevo
    ) VALUES (
        'UPDATE',
        NOW(),
        USER(),
        OLD.lib_isbn,
        OLD.lib_titulo,
        NEW.lib_titulo,
        OLD.lib_genero,
        NEW.lib_genero,
        OLD.lib_numeroPaginas,
        NEW.lib_numeroPaginas,
        OLD.lib_diasPrestamo,
        NEW.lib_diasPrestamo
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER trg_auditoria_libro_delete AFTER DELETE ON tbl_libro FOR EACH ROW BEGIN
    INSERT INTO tbl_auditoria_libro (
        lib_isbn,
        lib_titulo,
        old_lib_autor,
        old_lib_editorial,
        old_lib_numpaginas,
        old_lib_titulo,
        operacion,
        usuario,
        fecha
    )
    VALUES (
        OLD.lib_isbn,
        OLD.lib_titulo,
        (SELECT aut_apellido FROM tbl_autor WHERE aut_codigo = OLD.lib_isbn), -- Si la autoría está ligada al ISBN o a algún campo específico
        lib_editorial,
        lib_numeroPaginas,
        lib_titulo,
        'DELETE',
        USER(),
        NOW()
    );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla tbl_prestamo
--

CREATE TABLE tbl_prestamo (
  pres_id varchar(45) NOT NULL,
  pres_fechaPrestamo date NOT NULL,
  pres_fechaDevolucion date NOT NULL,
  soc_copiaNumero int(11) NOT NULL,
  lib_copiaISBN bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla tbl_prestamo
--

INSERT INTO tbl_prestamo (pres_id, pres_fechaPrestamo, pres_fechaDevolucion, soc_copiaNumero, lib_copiaISBN) VALUES
('pres1', '2023-01-15', '2023-01-20', 1, 1234567890),
('pres2', '2023-02-03', '2023-02-04', 2, 9999999999),
('pres3', '2023-04-09', '2023-04-11', 6, 2718281828),
('pres4', '2023-06-14', '2023-06-15', 9, 8888888888),
('pres5', '2023-07-02', '2023-07-09', 10, 5555555555),
('pres6', '2023-08-19', '2023-08-26', 12, 5555555555),
('pres7', '2023-10-24', '2023-10-27', 3, 1357924680),
('pres8', '2023-11-11', '2023-11-12', 4, 9999999999);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla tbl_socio
--

CREATE TABLE tbl_socio (
  soc_numero int(11) NOT NULL,
  soc_nombre varchar(45) NOT NULL,
  soc_apellido varchar(45) NOT NULL,
  soc_direccion varchar(45) NOT NULL,
  soc_telefono varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla tbl_socio
--

INSERT INTO tbl_socio (soc_numero, soc_nombre, soc_apellido, soc_direccion, soc_telefono) VALUES
(1, 'Ana', 'Ruiz', 'Calle Primavera 123, Ciudad Jardín, Barcelona', '9123456780'),
(2, 'Andrés Felipe', 'Galindo Luna', 'Avenida del Sol 456, Pueblo Nuevo, Madrid', '2123456789'),
(3, 'Juan', 'González', 'Calle Principal 789, Villa Flores, Valencia', '2012345678'),
(4, 'María', 'Rodríguez', 'Carrera del Río 321, El Pueblo, Sevilla', '3012345678'),
(5, 'Pedro', 'Martínez', 'Calle del Bosque 654, Los Pinos, Málaga', '1234567812'),
(6, 'Ana', 'López', 'Avenida Central 987, Villa Hermosa, Bilbao', '6123456781'),
(7, 'Carlos', 'Sánchez', 'Calle de la Luna 234, El Prado, Alicante', '1123456781'),
(8, 'Laura', 'Ramírez', 'Carrera del Mar 567, Playa Azul, Palma de Mal', '1312345678'),
(9, 'Luis', 'Hernández', 'Avenida de la Montaña 890, Monte Verde, Grana', '6101234567'),
(10, 'Andrea', 'García', 'Calle del Sol 432, La Colina, Zaragoza', '1112345678'),
(11, 'Alejandro', 'Torres', 'Carrera del Oeste 765, Ciudad Nueva, Murcia', '4951234567'),
(12, 'Sofia', 'Morales', 'Nueva Calle 456', '555-6789'),
(13, 'Juan', 'Pérez', 'Calle 72 # 2', '2928088');

--
-- Disparadores tbl_socio
--
DELIMITER $$
CREATE TRIGGER socios_after_delete AFTER DELETE ON tbl_socio FOR EACH ROW INSERT INTO audi_socio(
    socNumero_audi,
    socNombre_anterior,
    socApellido_anterior,
    socDireccion_anterior,
    socTelefono_anterior,
    audi_fechaModificacion,
    audi_usuario,
    audi_accion)
    VALUES(
    old.soc_numero,
    old.soc_nombre,
    old.soc_apellido,
    old.soc_direccion,
    old.soc_telefono,
    NOW(),
    CURRENT_USER(),
    'Registro eliminado')
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER socios_before_update BEFORE UPDATE ON tbl_socio FOR EACH ROW INSERT INTO audi_socio(
    socNumero_audi,
    socNombre_anterior,
    socApellido_anterior,
    socDireccion_anterior,
    socTelefono_anterior,
    socNombre_nuevo,
    socApellido_nuevo,
    socDireccion_nuevo,
    socTelefono_nuevo,
    audi_fechaModificacion,
    audi_usuario,
    audi_accion)
    VALUES(
    new.soc_numero,
    old.soc_nombre,
    old.soc_apellido,
    old.soc_direccion,
    old.soc_telefono,
    new.soc_nombre,
    new.soc_apellido,
    new.soc_direccion,
    new.soc_telefono,
    NOW(),
    CURRENT_USER(),
    'Actualización')
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER trg_audit_insert_socio AFTER INSERT ON tbl_socio FOR EACH ROW BEGIN
    INSERT INTO audi_socio (
        audi_accion, 
        audi_fechaModificacion, 
        audi_usuario, 
        socNumero_audi, 
        socNombre_nuevo, 
        socApellido_nuevo, 
        socDireccion_nuevo, 
        socTelefono_nuevo
    ) VALUES (
        'INSERT', 
        NOW(), 
        USER(),  
        NEW.soc_numero,
        NEW.soc_nombre,
        NEW.soc_apellido,
        NEW.soc_direccion,
        NEW.soc_telefono
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER trg_audit_update_socio AFTER UPDATE ON tbl_socio FOR EACH ROW BEGIN
    INSERT INTO audi_socio (
        audi_accion, 
        audi_fechaModificacion, 
        audi_usuario, 
        socNumero_audi, 
        socNombre_anterior, 
        socNombre_nuevo, 
        socApellido_anterior, 
        socApellido_nuevo, 
        socDireccion_anterior, 
        socDireccion_nuevo, 
        socTelefono_anterior, 
        socTelefono_nuevo
    ) VALUES (
        'UPDATE', 
        NOW(), 
        USER(),  -- Aquí puedes reemplazar USER() con el nombre de usuario si se requiere algo específico
        OLD.soc_numero,
        OLD.soc_nombre,
        NEW.soc_nombre,
        OLD.soc_apellido,
        NEW.soc_apellido,
        OLD.soc_direccion,
        NEW.soc_direccion,
        OLD.soc_telefono,
        NEW.soc_telefono
    );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla tbl_tipoautores
--

CREATE TABLE tbl_tipoautores (
  copiaISBN bigint(20) NOT NULL,
  copiaAutor int(11) NOT NULL,
  tipoAutor varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla tbl_tipoautores
--

INSERT INTO tbl_tipoautores (copiaISBN, copiaAutor, tipoAutor) VALUES
(0, 0, 'tipoAutor'),
(1357924680, 123, 'Traductor'),
(1234567890, 123, 'Autor'),
(1234567890, 456, 'Coautor'),
(2718281828, 789, 'Traductor'),
(8888888888, 234, 'Autor'),
(2468135790, 234, 'Autor'),
(9876543210, 567, 'Autor'),
(1234567890, 890, 'Autor'),
(8642097531, 345, 'Autor'),
(8888888888, 345, 'Coautor'),
(5555555555, 678, 'Autor'),
(3141592653, 901, 'Autor'),
(9517530862, 432, 'Autor'),
(7777777777, 765, 'Autor'),
(9999999999, 98, 'Autor');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista vista_libros_en_prestamo
-- (Véase abajo para la vista actual)
--
CREATE TABLE vista_libros_en_prestamo (
lib_isbn bigint(20)
,lib_titulo varchar(45)
,soc_numero int(11)
,soc_nombre varchar(45)
,soc_apellido varchar(45)
,aut_apellido varchar(45)
,pres_fechaPrestamo date
,pres_fechaDevolucion date
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista vista_lista_autores
-- (Véase abajo para la vista actual)
--
CREATE TABLE vista_lista_autores (
aut_codigo int(11)
,aut_apellido varchar(45)
,aut_nacimiento date
,aut_muerte date
);

-- --------------------------------------------------------

--
-- Estructura para la vista vista_libros_en_prestamo
--
DROP TABLE IF EXISTS vista_libros_en_prestamo;

CREATE ALGORITHM=UNDEFINED DEFINER=root@localhost SQL SECURITY DEFINER VIEW vista_libros_en_prestamo  AS SELECT l.lib_isbn AS lib_isbn, l.lib_titulo AS lib_titulo, s.soc_numero AS soc_numero, s.soc_nombre AS soc_nombre, s.soc_apellido AS soc_apellido, a.aut_apellido AS aut_apellido, p.pres_fechaPrestamo AS pres_fechaPrestamo, p.pres_fechaDevolucion AS pres_fechaDevolucion FROM ((((tbl_prestamo p join tbl_libro l on(p.lib_copiaISBN = l.lib_isbn)) join tbl_socio s on(p.soc_copiaNumero = s.soc_numero)) join tbl_tipoautores ta on(l.lib_isbn = ta.copiaISBN)) join tbl_autor a on(ta.copiaAutor = a.aut_codigo)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista vista_lista_autores
--
DROP TABLE IF EXISTS vista_lista_autores;

CREATE ALGORITHM=UNDEFINED DEFINER=root@localhost SQL SECURITY DEFINER VIEW vista_lista_autores  AS SELECT tbl_autor.aut_codigo AS aut_codigo, tbl_autor.aut_apellido AS aut_apellido, tbl_autor.aut_nacimiento AS aut_nacimiento, tbl_autor.aut_muerte AS aut_muerte FROM tbl_autor ORDER BY tbl_autor.aut_apellido ASC ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla audi_socio
--
ALTER TABLE audi_socio
  ADD PRIMARY KEY (id_audi);

--
-- Indices de la tabla tbl_auditoria_libro
--
ALTER TABLE tbl_auditoria_libro
  ADD PRIMARY KEY (audit_id);

--
-- Indices de la tabla tbl_autor
--
ALTER TABLE tbl_autor
  ADD PRIMARY KEY (aut_codigo);

--
-- Indices de la tabla tbl_libro
--
ALTER TABLE tbl_libro
  ADD PRIMARY KEY (lib_isbn);

--
-- Indices de la tabla tbl_prestamo
--
ALTER TABLE tbl_prestamo
  ADD PRIMARY KEY (pres_id),
  ADD KEY soc_copiaNumero (soc_copiaNumero),
  ADD KEY lib_copiaISBN (lib_copiaISBN);

--
-- Indices de la tabla tbl_socio
--
ALTER TABLE tbl_socio
  ADD PRIMARY KEY (soc_numero);

--
-- Indices de la tabla tbl_tipoautores
--
ALTER TABLE tbl_tipoautores
  ADD KEY copiaISBN (copiaISBN),
  ADD KEY copiaAutor (copiaAutor);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla audi_socio
--
ALTER TABLE audi_socio
  MODIFY id_audi int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla tbl_auditoria_libro
--
ALTER TABLE tbl_auditoria_libro
  MODIFY audit_id int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla tbl_prestamo
--
ALTER TABLE tbl_prestamo
  ADD CONSTRAINT tbl_prestamo_ibfk_1 FOREIGN KEY (soc_copiaNumero) REFERENCES tbl_socio (soc_numero),
  ADD CONSTRAINT tbl_prestamo_ibfk_2 FOREIGN KEY (lib_copiaISBN) REFERENCES tbl_libro (lib_isbn);

--
-- Filtros para la tabla tbl_tipoautores
--
ALTER TABLE tbl_tipoautores
  ADD CONSTRAINT tbl_tipoautores_ibfk_1 FOREIGN KEY (copiaISBN) REFERENCES tbl_libro (lib_isbn),
  ADD CONSTRAINT tbl_tipoautores_ibfk_2 FOREIGN KEY (copiaAutor) REFERENCES tbl_autor (aut_codigo);

DELIMITER $$
--
-- Eventos
--
CREATE DEFINER=root@localhost EVENT anual_eliminar_prestamos ON SCHEDULE EVERY 1 YEAR STARTS '2024-08-13 15:01:18' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
DELETE FROM tbl_prestamo
WHERE pres_fechaDevolucion <= NOW() - INTERVAL 1 YEAR;
#datos menores a la fecha actual - 1 año
END$$

CREATE DEFINER=root@localhost EVENT hora_eliminar_prestamos ON SCHEDULE EVERY 1 HOUR STARTS '2024-08-13 15:01:18' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
DELETE FROM tbl_prestamo
WHERE pres_fechaDevolucion <= NOW() - INTERVAL 1 MONTH;
#datos menores a la fecha actual - 1 mes
END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;