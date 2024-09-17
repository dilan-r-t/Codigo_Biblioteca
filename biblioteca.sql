-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 17-09-2024 a las 21:31:10
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `biblioteca`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE  PROCEDURE `Actualizar_Telefono_Direccion` (IN `numero` INT, IN `direccion` VARCHAR(255), IN `telefono` VARCHAR(20))   BEGIN
    UPDATE socio
    SET
        direccion = direccion,
        telefono = telefono
    WHERE numero = numero;
END$$

CALL Actualizar_Telefono_Direccion('');

----------------------------------------------------------------------------------------------------------------------------------------
CREATE  PROCEDURE `Buscar_Libro_Por_Nombre` (IN `p_titulo` VARCHAR(255))
BEGIN
    SELECT 
        ISBN,
        titulo,
        numero_Paginas,
        genero,
        dias_Prestamo
    FROM libro
    WHERE titulo LIKE CONCAT('%', p_titulo, '%');
END$$

CALL Buscar_Libro_PorNombre('');
------------------------------------------------------------------------------------------------------------------------------------------


DELIMITER $$

CREATE PROCEDURE `Eliminar_Libro` (IN `p_lib_isbn` BIGINT)   BEGIN
   
    IF NOT EXISTS (SELECT 1 FROM prestamo WHERE copia_ISBN = ISBN) THEN
    
        DELETE FROM libro WHERE ISBN = ISBN;
    ELSE
        
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar el libro porque tiene dependencias en tbl_prestamo.';
    END IF;
END$$

CALL Eliminar_Libro('');

------------------------------------------------------------------------------------------------------------------------------------------------

DELIMITER $$

CREATE  PROCEDURE `get_lista_Autores` ()   SELECT codigo, apellido
FROM autor
ORDER BY apellido DESC$$

CALL get_lista_Autores();
---------------------------------------------------------------------------------------------------------------

CREATE  PROCEDURE `get_tipo_Autor` (`variable` VARCHAR(20))   SELECT apellido as 'Autor', tipo_Autor
FROM autor
INNER JOIN tipo_autor
ON codigo=copia_Autor
WHERE tipo_Autor=variable$$

CALL get_tipo_Autor('');
--------------------------------------------------------------------------------------------------------------------------------------

CREATE  PROCEDURE `insertar_libro` (`c1_ISBN` BIGINT(20), `c2_titulo` VARCHAR(255), `c3_genero` VARCHAR(20), `c4_paginas` INT(11), `c5diaspres` TINYINT(4))   INSERT INTO
libro(ISBN, titulo, genero, numero_Paginas,dias_Prestamo)
VALUES (c1_ISBN,c2_titulo,c3_genero, c4_paginas,c5dias_prestamo)$$

CALL insertar_libro();
------------------------------------------------------------------------------------------------------------------------------------------


CREATE PROCEDURE `Insertar_Socio` (IN `numero` INT, IN `nombre` VARCHAR(100), IN `apellido` VARCHAR(100), IN `direccion` VARCHAR(255), IN `telefono` VARCHAR(20))   BEGIN
    INSERT INTO socio (
        numero,
        nombre,
        apellido,
        direccion,
        telefono
    ) VALUES (
        numero,
        nombre,
        apellido,
        direccion,
        telefono
    );
END$$

CALL Insertar_Socio('');
--------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE PROCEDURE `Listar_Libros_En_Prestamo_Con_Autor` ()   BEGIN
    SELECT
        l.ISBN,
        l.Titulo,
        s.Numero AS Numero_Socio,
        s.Nombre AS Nombre_Socio,
        s.Apellido AS Apellido_Socio,
        a.Apellido AS Apellido_Autor,
        p.Fecha_Prestamo,
        p.Fecha_Devolucion
    FROM prestamo p
    INNER JOIN libro l ON p.Copia_ISBN = l.ISBN
    INNER JOIN socio s ON p.Copia_Numero = s.Numero
    INNER JOIN tipo_autores ta ON l.ISBN = ta.Copia_ISBN
    INNER JOIN autor a ON ta.Copia_Autor = a.Codigo;
    
END$$

CALL Listar_Libros_En_Prestamo_Con_Autor();
------------------------------------------------------------------------------------------------------------------------------------------

CREATE  PROCEDURE `Lista_Autores` ()   BEGIN
    -- Seleccionar todos los autores de la tabla autor
    SELECT 
        Codigo,
        Nombre,
        Apellido
    FROM 
        autor;
END$$
CALL Lista_Autores();
-----------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE `Obtener_Socios_Con_Prestamos` ()   BEGIN 
SELECT s.Numero, s.Nombre, p.prestamo_id, p.Fecha_Prestamo 
FROM socio s LEFT JOIN prestamo p ON s.Numero = 
p.Copia_Numero;

END$$

CALL Obtener_Socios_Con_Prestamos();
-----------------------------------------------------------------------------------------------------------------------------------
--
-- Funciones
--
CREATE FUNCTION `Contar_Socios` () RETURNS INT(11)  BEGIN
    DECLARE socios INT;
    SELECT COUNT(*) INTO socios FROM socio;
    RETURN socios;
END$$

SELECT Contar_Socios();
--------------------------------------------------------------------------------------------------------------------------------------

CREATE FUNCTION `Dias_En_Prestamo` (`ISBN`) RETURNS INT(11)  BEGIN
    DECLARE total_dias INT DEFAULT 0;

    -- Sumar la diferencia en días entre fecha de devolución y fecha de préstamo para el libro especificado
    SELECT COALESCE(SUM(DATEDIFF(Fecha_Devolucion, Fecha_Prestamo)), 0)
    INTO total_dias
    FROM Prestamo
    WHERE Copia_ISBN = ISBN AND Fecha_Devolucion IS NOT NULL;

    -- Devolver el total de días
    RETURN total_dias;
END$$

DELIMITER ;

SELECT Dias_En_Prestamo();
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria_autor`
--

CREATE TABLE `auditoria_autor` (
  `auditoria_accion` varchar(50) DEFAULT NULL,
  `auditoria_fecha_Modificacion` datetime DEFAULT NULL,
  `auditoria_usuario` varchar(255) DEFAULT NULL,
  `codigo` int(11) DEFAULT NULL,
  `apellido` varchar(255) DEFAULT NULL,
  `muerte` date DEFAULT NULL,
  `nacimiento` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria_socio`
--

CREATE TABLE `auditoria_socio` (
  `id_auditoria` int(10) NOT NULL,
  `Numero_auditoria` int(11) DEFAULT NULL,
  `Nombre_anterior` varchar(45) DEFAULT NULL,
  `Apellido_anterior` varchar(45) DEFAULT NULL,
  `Direccion_anterior` varchar(255) DEFAULT NULL,
  `Telefono_anterior` varchar(10) DEFAULT NULL,
  `Nombre_nuevo` varchar(45) DEFAULT NULL,
  `Apellido_nuevo` varchar(45) DEFAULT NULL,
  `Direccion_nuevo` varchar(255) DEFAULT NULL,
  `Telefono_nuevo` varchar(10) DEFAULT NULL,
  `auditoria_fecha_Modificacion` datetime DEFAULT NULL,
  `auditoria_usuario` varchar(10) DEFAULT NULL,
  `auditoria_accion` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `auditoria_socio`
--

INSERT INTO `auditoria_socio` (`id_auditoria`, `Numero_auditoria`, `Nombre_anterior`, `Apellido_anterior`, `Direccion_anterior`, `Telefono_anterior`, `Nombre_nuevo`, `Apellido_nuevo`, `Direccion_nuevo`, `Telefono_nuevo`, `auditoria_fecha_Modificacion`, `auditoria_usuario`, `auditoria_accion`) VALUES
(1, 13, 'Juan', 'Pérez', 'Calle Falsa 123', '555-1234', 'Juan', 'Pérez', 'Calle 72 # 2', '2928088', '2024-07-31 09:53:32', 'root@local', 'Actualización'),
(2, 0, NULL, NULL, NULL, NULL, 'Camila', 'Rodriguez', 'Narnia con calle 6', '4415574578', '2024-08-01 07:39:33', 'root@local', 'INSERT'),
(3, 0, 'Camila', 'Rodriguez', 'Narnia con calle 6', '4415574578', NULL, NULL, NULL, NULL, '2024-08-01 07:40:02', 'root@local', 'Registro eliminado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `autor`
--

CREATE TABLE `autor` (
  `codigo` int(11) NOT NULL,
  `apellido` varchar(45) NOT NULL,
  `nacimiento` date NOT NULL,
  `muerte` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `autor`
--

INSERT INTO `autor` (`codigo`, `apellido`, `nacimiento`, `muerte`) VALUES
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
-- Disparadores `autor`
--
DELIMITER $$
CREATE TRIGGER `trg_audit_delete_autor` AFTER DELETE ON `autor` FOR EACH ROW BEGIN
    INSERT INTO autor (
        auditoria_accion, 
        auditoria_fecha_Modificacion, 
        auditoria_usuario, 
        codigo, 
        apellido, 
        muerte, 
        nacimiento
    ) VALUES (
        'DELETE', 
        NOW(), 
        USER(),  -- Aquí puedes reemplazar USER() con el nombre de usuario si se requiere algo específico
        OLD.codigo,
        OLD.apellido,
        OLD.muerte,
        OLD.nacimiento
    );
END
$$
DELIMITER ;

DELETE FROM autor WHERE codigo =;
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `libro`
--

CREATE TABLE `libro` (
  `isbn` bigint(20) NOT NULL,
  `titulo` varchar(45) NOT NULL,
  `genero` varchar(45) NOT NULL,
  `numero_Paginas` int(11) NOT NULL,
  `dias_Prestamo` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `libro`
--

INSERT INTO `libro` (`isbn`, `titulo`, `genero`, `numero_Paginas`, `dias_Prestamo`) VALUES
(0, 'titulo', 'genero', 0, 0),
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
-- Disparadores `libro`
--
DELIMITER $$
CREATE TRIGGER `trg_audit_update_libro_v2` BEFORE UPDATE ON `libro` FOR EACH ROW BEGIN
    DECLARE v_accion VARCHAR(10);
    DECLARE v_fecha_Modificacion DATETIME;
    DECLARE v_usuario VARCHAR(255);

    -- Asignación de valores
    SET v_accion = 'UPDATE';
    SET v_fecha_Modificacion = NOW();
    SET v_usuario = USER();

    -- Inserción en la tabla de auditoría
    INSERT INTO auditoria_libro (
        auditoria_accion,
        auditoria_fecha_Modificacion,
        auditoria_usuario,
        ISBN,
        titulo_anterior,
        titulo_nuevo,
        genero_anterior,
        genero_nuevo,
        numero_Paginas_anterior,
        numero_Paginas_nuevo,
        dias_Prestamo_anterior,
        dias_Prestamo_nuevo
    ) VALUES (
        v_accion,
        v_fecha_Modificacion,
        v_usuario,
        OLD.ISBN,
        OLD.titulo,
        NEW.titulo,
        OLD.genero,
        NEW.genero,
        OLD.numero_Paginas,
        NEW.numero_Paginas,
        OLD.dias_Prestamo,
        NEW.dias_Prestamo
    );
END
$$
DELIMITER ;

UPDATE libro
SET titulo = 'Nuevo Título', numero_Paginas = 350
WHERE ISBN = 9781234567897;
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `prestamo`
--

CREATE TABLE `prestamo` (
  `prestamo_id` varchar(45) NOT NULL,
  `fecha_Prestamo` date NOT NULL,
  `fecha_Devolucion` date NOT NULL,
  `copia_Numero` int(11) NOT NULL,
  `copia_ISBN` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `prestamo`
--

INSERT INTO `prestamo` (`prestamo_id`, `fecha_Prestamo`, `fecha_Devolucion`, `copia_Numero`, `copia_ISBN`) VALUES
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
-- Estructura de tabla para la tabla `socio`
--

CREATE TABLE `socio` (
  `numero` int(11) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `apellido` varchar(45) NOT NULL,
  `direccion` varchar(45) NOT NULL,
  `telefono` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `socio`
--

INSERT INTO `socio` (`numero`, `nombre`, `apellido`, `direccion`, `telefono`) VALUES
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
-- Disparadores `socio`
--
DELIMITER $$
CREATE TRIGGER `socios_after_delete` AFTER DELETE ON `socio` FOR EACH ROW INSERT INTO audi_socio(
    Numero_auditoria,
    Nombre_anterior,
    Apellido_anterior,
    Direccion_anterior,
    Telefono_anterior,
    audi_fecha_Modificacion,
    auditoria_usuario,
    auditoria_accion)
    VALUES(
    old.numero,
    old.nombre,
    old.apellido,
    old.direccion,
    old.telefono,
    NOW(),
    CURRENT_USER(),
    'Registro eliminado')
$$
DELIMITER ;

DELETE FROM socio WHERE numero = ;
-------------------------------------------------------------------------------------------------------------------------------

DELIMITER $$
CREATE TRIGGER `socios_before_update` BEFORE UPDATE ON `socio` FOR EACH ROW INSERT INTO auditoria_socio(
    Numero_auditoria,
    Nombre_anterior,
    Apellido_anterior,
    Direccion_anterior,
    Telefono_anterior,
    Nombre_nuevo,
    Apellido_nuevo,
    Direccion_nuevo,
    Telefono_nuevo,
    auditoria_fechaModificacion,
    auditoria_usuario,
    auditoria_accion)
    VALUES(
    new.numero,
    old.nombre,
    old.apellido,
    old.direccion,
    old.telefono,
    new.nombre,
    new.apellido,
    new.direccion,
    new.telefono,
    NOW(),
    CURRENT_USER(),
    'Actualización')
$$
DELIMITER ;

  UPDATE socio
SET nombre = '', apellido = ''
WHERE numero = ;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

DELIMITER $$
CREATE TRIGGER `trg_audit_insert_socio` AFTER INSERT ON `socio` FOR EACH ROW BEGIN
    INSERT INTO auditoria_socio (
        auditoria_accion, 
        auditoria_fecha_Modificacion, 
        auditoria_usuario, 
        Numero_auditoria, 
        Nombre_nuevo, 
        Apellido_nuevo, 
        Direccion_nuevo, 
        Telefono_nuevo
    ) VALUES (
        'INSERT', 
        NOW(), 
        USER(),  
        NEW.numero,
        NEW.nombre,
        NEW.apellido,
        NEW.direccion,
        NEW.telefono
    );
END
$$
DELIMITER ;

INSERT INTO socio (numero, nombre, apellido, direccion, telefono)
VALUES (123, 'Juan', 'Pérez', 'Calle Falsa 123', '555-1234');
---------------------------------------------------------------------

DELIMITER $$
CREATE TRIGGER `trg_audit_update_socio` AFTER UPDATE ON `socio` FOR EACH ROW BEGIN
    INSERT INTO auditoria_socio (
        auditoria_accion, 
        auditoria_fecha_Modificacion, 
        auditoria_usuario, 
        Numero_auditoria, 
        Nombre_anterior, 
        Nombre_nuevo, 
        Apellido_anterior, 
        Apellido_nuevo, 
        Direccion_anterior, 
        Direccion_nuevo, 
        Telefono_anterior, 
        Telefono_nuevo
    ) VALUES (
        'UPDATE', 
        NOW(), 
        USER(),  -- Aquí puedes reemplazar USER() con el nombre de usuario si se requiere algo específico
        OLD.numero,
        OLD.nombre,
        NEW.nombre,
        OLD.apellido,
        NEW.apellido,
        OLD.direccion,
        NEW.direccion,
        OLD.telefono,
        NEW.telefono
    );
END
$$
DELIMITER ;

UPDATE socio
SET nombre = 'Carlos', apellido = 'García', direccion = 'Avenida Siempre Viva 742', telefono = '555-9876'
WHERE numero = 123;
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_autores`
--

CREATE TABLE `tipo_autores` (
  `copia_ISBN` bigint(20) NOT NULL,
  `copia_Autor` int(11) NOT NULL,
  `tipo_Autor` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipo_autores`
--

INSERT INTO `tipo_autores` (`copia_ISBN`, `copia_Autor`, `tipo_Autor`) VALUES
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
(9999999999, 98, 'Autor'),
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
-- Estructura Stand-in para la vista `vista_libros_mas_prestados`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_libros_mas_prestados` (
`titulo` varchar(45)
,`total_prestamos` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_socios_con_mas_prestamos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_socios_con_mas_prestamos` (
`nombre` varchar(45)
,`apellido` varchar(45)
,`total_prestamos` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_libros_mas_prestados`
--
DROP TABLE IF EXISTS `vista_libros_mas_prestados`;

CREATE  VIEW `vista_libros_mas_prestados`  AS SELECT `l`.`titulo` AS `titulo`, count(`p`.`prestamo_id`) AS `total_prestamos` FROM (`libro` `l` join `prestamo` `p` on(`l`.`isbn` = `p`.`copia_ISBN`)) GROUP BY `l`.`titulo` ORDER BY count(`p`.`prestamo_id`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_socios_con_mas_prestamos`
--
DROP TABLE IF EXISTS `vista_socios_con_mas_prestamos`;

CREATE  VIEW `vista_socios_con_mas_prestamos`  AS SELECT `s`.`nombre` AS `nombre`, `s`.`apellido` AS `apellido`, count(`p`.`prestamo_id`) AS `total_prestamos` FROM (`socio` `s` join `prestamo` `p` on(`s`.`numero` = `p`.`copia_Numero`)) WHERE `p`.`fecha_Devolucion` is null GROUP BY `s`.`nombre`, `s`.`apellido` ORDER BY count(`p`.`prestamo_id`) DESC ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `auditoria_socio`
--
ALTER TABLE `auditoria_socio`
  ADD PRIMARY KEY (`id_auditoria`);

--
-- Indices de la tabla `autor`
--
ALTER TABLE `autor`
  ADD PRIMARY KEY (`codigo`);

--
-- Indices de la tabla `libro`
--
ALTER TABLE `libro`
  ADD PRIMARY KEY (`isbn`),
  ADD KEY `titulo` (`titulo`);

--
-- Indices de la tabla `prestamo`
--
ALTER TABLE `prestamo`
  ADD PRIMARY KEY (`prestamo_id`),
  ADD KEY `copia_Numero` (`copia_Numero`),
  ADD KEY `copia_ISBN` (`copia_ISBN`);

--
-- Indices de la tabla `socio`
--
ALTER TABLE `socio`
  ADD PRIMARY KEY (`numero`);

--
-- Indices de la tabla `tipo_autores`
--
ALTER TABLE `tipo_autores`
  ADD KEY `copia_ISBN` (`copia_ISBN`),
  ADD KEY `copia_Autor` (`copia_Autor`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `auditoria_socio`
--
ALTER TABLE `auditoria_socio`
  MODIFY `id_auditoria` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `prestamo`
--
ALTER TABLE `prestamo`
  ADD CONSTRAINT `prestamo_ibfk_1` FOREIGN KEY (`copia_Numero`) REFERENCES `socio` (`numero`),
  ADD CONSTRAINT `prestamo_ibfk_2` FOREIGN KEY (`copia_ISBN`) REFERENCES `libro` (`isbn`);

--
-- Filtros para la tabla `tipo_autores`
--
ALTER TABLE `tipo_autores`
  ADD CONSTRAINT `tbl_tipoautores_ibfk_2` FOREIGN KEY (`copia_Autor`) REFERENCES `autor` (`codigo`),
  ADD CONSTRAINT `tipo_autores_ibfk_1` FOREIGN KEY (`copia_ISBN`) REFERENCES `libro` (`isbn`);

DELIMITER $$
--
-- Eventos
--
CREATE  EVENT `anual_eliminar_prestamos` ON SCHEDULE EVERY 1 YEAR STARTS '2024-08-08 14:56:01' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
DELETE FROM prestamo
WHERE fecha_Devolucion <= NOW() - INTERVAL 1 YEAR;
#datos menores a la fecha actual - 1 año
END$$
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE EVENT `hora_eliminar_prestamos` ON SCHEDULE EVERY 1 HOUR STARTS '2024-08-08 14:56:27' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
DELETE FROM prestamo
WHERE fecha_Devolucion <= NOW() - INTERVAL 1 MONTH;
#datos menores a la fecha actual - 1 mes
END$$
---------------------------------------------------------------------------------------------------------------------------------------------

CREATE  EVENT `evento_eliminar_prestamos` ON SCHEDULE EVERY 1 DAY STARTS '2024-08-08 15:16:36' ON COMPLETION NOT PRESERVE ENABLE DO DELETE FROM prestamo
  WHERE fecha_Devolucion < CURDATE()$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
