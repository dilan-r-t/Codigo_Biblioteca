-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 09-08-2024 a las 03:18:29
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
-- Base de datos: `taller_final`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_socio` (IN `p_socio_id` INT, IN `p_telefono` VARCHAR(20), IN `p_direccion` VARCHAR(255))   BEGIN
    UPDATE socio
    SET telefono = p_telefono,
        direccion = p_direccion
    WHERE socio_id = p_socio_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `buscar_libro_por_nombre` (IN `p_nombre` VARCHAR(255))   BEGIN
    SELECT * 
    FROM libros 
    WHERE nombre LIKE CONCAT('%', p_nombre, '%');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_libro` (IN `p_isbn` VARCHAR(13))   BEGIN
    -- Verificar si el libro tiene dependencias en la tabla prestamo
    IF NOT EXISTS (SELECT 1 FROM prestamo WHERE isbn = p_isbn) THEN
        -- Si no hay dependencias, eliminar el libro
        DELETE FROM libros WHERE isbn = p_isbn;
    ELSE
        -- Si hay dependencias, mostrar un mensaje
        SELECT 'El libro tiene dependencias y no puede ser eliminado.' AS mensaje;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_lista_Autores` ()   BEGIN
    SELECT * FROM autores;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_tipo_Autor` (IN `tipoAutor` VARCHAR(20))   BEGIN
    SELECT * FROM autores WHERE tipo = tipoAutor;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertar_libro` (IN `c1_isbn` VARCHAR(13), IN `c1_titulo` VARCHAR(255), IN `c1_autor` VARCHAR(255), IN `c1_anio` INT)   BEGIN
    INSERT INTO libros (isbn, titulo, autor, anio)
    VALUES (c1_isbn, c1_titulo, c1_autor, c1_anio);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_socio` (IN `p_socio_id` INT, IN `p_nombre` VARCHAR(255), IN `p_direccion` VARCHAR(255), IN `p_telefono` VARCHAR(20), IN `p_email` VARCHAR(100))   BEGIN
    INSERT INTO socio (socio_id, nombre, direccion, telefono, email)
    VALUES (p_socio_id, p_nombre, p_direccion, p_telefono, p_email);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listar_libros_prestamo` ()   BEGIN
    SELECT l.*, s.*, p.*
    FROM libros l
    INNER JOIN prestamo p ON l.isbn = p.isbn
    INNER JOIN socio s ON p.socio_id = s.socio_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `socio_prestamo` ()   BEGIN
    SELECT s.*, p.*
    FROM socio s
    LEFT JOIN prestamo p ON s.socio_id = p.socio_id;
END$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `contar_socios` () RETURNS INT(11)  BEGIN
    DECLARE total_socios INT DEFAULT 0;
    DECLARE done INT DEFAULT 0;
    DECLARE socio_id INT;

    -- Declarar un cursor para seleccionar los IDs de la tabla socio
    DECLARE cursor_socios CURSOR FOR SELECT id FROM socio;

    -- Declarar el manejador de finalización del cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Abrir el cursor
    OPEN cursor_socios;

    -- Bucle para contar los socios
    read_loop: LOOP
        FETCH cursor_socios INTO socio_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET total_socios = total_socios + 1;
    END LOOP;

    -- Cerrar el cursor
    CLOSE cursor_socios;

    RETURN total_socios;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `dias_en_prestamo` (`p_isbn` VARCHAR(13)) RETURNS INT(11)  BEGIN
    DECLARE dias INT;
    DECLARE fecha_inicio DATE;
    DECLARE fecha_fin DATE;
    DECLARE fecha_fin_actual DATE;
    
    -- Obtener la fecha de inicio del préstamo más reciente
    SELECT fecha_inicio INTO fecha_inicio
    FROM prestamo
    WHERE isbn = p_isbn
    ORDER BY fecha_inicio DESC
    LIMIT 1;

    -- Obtener la fecha de fin del préstamo más reciente
    SELECT fecha_fin INTO fecha_fin
    FROM prestamo
    WHERE isbn = p_isbn
    ORDER BY fecha_inicio DESC
    LIMIT 1;

    -- Si la fecha de fin es NULL, usar la fecha actual
    SET fecha_fin_actual = IF(fecha_fin IS NULL, CURDATE(), fecha_fin);

    -- Calcular el número de días en préstamo
    SET dias = DATEDIFF(fecha_fin_actual, fecha_inicio);

    RETURN dias;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria_autor`
--

CREATE TABLE `auditoria_autor` (
  `id_auditoria` int(11) NOT NULL,
  `Apellido` varchar(10) DEFAULT NULL,
  `Muerte` date DEFAULT NULL,
  `Nacimiento` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria_libro`
--

CREATE TABLE `auditoria_libro` (
  `id` int(11) NOT NULL,
  `libro_isbn` bigint(20) DEFAULT NULL,
  `campo_modificado` varchar(255) DEFAULT NULL,
  `valor_anterior` text DEFAULT NULL,
  `valor_nuevo` text DEFAULT NULL,
  `fecha_modificacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `usuario` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria_socio`
--

CREATE TABLE `auditoria_socio` (
  `id_auditoria` int(11) NOT NULL,
  `operacion` varchar(10) DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  `antiguo_nombre` varchar(255) DEFAULT NULL,
  `nuevo_nombre` varchar(255) DEFAULT NULL,
  `antiguo_direccion` varchar(255) DEFAULT NULL,
  `nueva_direccion` varchar(255) DEFAULT NULL,
  `antiguo_telefono` varchar(20) DEFAULT NULL,
  `nuevo_telefono` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `autor`
--

CREATE TABLE `autor` (
  `Codigo` int(255) NOT NULL,
  `Apellido` varchar(255) NOT NULL,
  `Nacimiento` date NOT NULL,
  `Muerte` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `autor`
--

INSERT INTO `autor` (`Codigo`, `Apellido`, `Nacimiento`, `Muerte`) VALUES
(0, 'Apellido', '0000-00-00', '2021-12-09'),
(98, 'Smith', '1974-12-21', '2018-07-21'),
(123, 'Taylor', '1980-04-15', '0000-00-00'),
(234, 'Medina', '1977-06-21', '2005-09-12'),
(345, 'Wilson', '1975-08-29', '0000-00-00'),
(432, 'Miller', '1981-10-26', '0000-00-00'),
(456, 'García', '1978-09-27', '2021-12-09'),
(567, 'Davis', '1983-03-04', '2010-03-28'),
(678, 'Silva', '1986-02-02', '0000-00-00'),
(765, 'López', '1976-07-08', '2024-09-20'),
(789, 'Rodríguez', '1985-12-10', '0000-00-00'),
(890, 'Brown', '1982-11-17', '0000-00-00'),
(901, 'Soto', '1979-05-13', '2015-11-05');

--
-- Disparadores `autor`
--
DELIMITER $$
CREATE TRIGGER `auditoria_autor_delete` BEFORE DELETE ON `autor` FOR EACH ROW BEGIN
    INSERT INTO auditoria_autor_delete (
        Apellido,
        Muerte,
        Nacimiento
    )
    VALUES (
        'DELETE',
        OLD.Apellido,
        OLD.Nacimiento
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `auditoria_autor_insert` AFTER INSERT ON `autor` FOR EACH ROW BEGIN
    INSERT INTO auditoria_autor (
        Apellido,
        Muerte,
        Nacimiento
    )
    VALUES (

        'INSERT',
        NEW.Apellido,
        NEW.Nacimiento
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `auditoria_autor_update` BEFORE UPDATE ON `autor` FOR EACH ROW BEGIN
    INSERT INTO auditoria_autor_update (
        Apellido,
        antiguo_Apellido,
        nuevo_Apellido,
        antigua_Nacimiento,
        nueva_Nacimiento
    )
    VALUES (
        'UPDATE',
        OLD.Apellido,
        NEW.Apellido,
        OLD.Nacimiento,
        NEW.Nacimiento
    );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `libro`
--

CREATE TABLE `libro` (
  `ISBN` bigint(255) NOT NULL,
  `Titulo` varchar(255) NOT NULL,
  `Genero` varchar(255) NOT NULL,
  `Numero_Paginas` int(255) NOT NULL,
  `Dias_Prestamo` tinyint(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `libro`
--

INSERT INTO `libro` (`ISBN`, `Titulo`, `Genero`, `Numero_Paginas`, `Dias_Prestamo`) VALUES
(0, 'Titulo', 'Genero', 0, 0),
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
(9999999999, 'El Enigma de los Espejos Rotos', 'romance', 156, 7);

--
-- Disparadores `libro`
--
DELIMITER $$
CREATE TRIGGER `trg_libro_auditoria` AFTER UPDATE ON `libro` FOR EACH ROW BEGIN
    -- Auditar el campo 'Titulo'
    IF OLD.Titulo != NEW.Titulo THEN
        INSERT INTO auditoria_libro (libro_isbn, campo_modificado, valor_anterior, valor_nuevo, usuario)
        VALUES (OLD.ISBN, 'Titulo', OLD.Titulo, NEW.Titulo, USER());
    END IF;

    -- Auditar el campo 'Genero'
    IF OLD.Genero != NEW.Genero THEN
        INSERT INTO auditoria_libro (libro_isbn, campo_modificado, valor_anterior, valor_nuevo, usuario)
        VALUES (OLD.ISBN, 'Genero', OLD.Genero, NEW.Genero, USER());
    END IF;

    -- Auditar el campo 'Numero_Paginas'
    IF OLD.Numero_Paginas != NEW.Numero_Paginas THEN
        INSERT INTO auditoria_libro (libro_isbn, campo_modificado, valor_anterior, valor_nuevo, usuario)
        VALUES (OLD.ISBN, 'Numero_Paginas', OLD.Numero_Paginas, NEW.Numero_Paginas, USER());
    END IF;

    -- Auditar el campo 'Dias_Prestamo'
    IF OLD.Dias_Prestamo != NEW.Dias_Prestamo THEN
        INSERT INTO auditoria_libro (libro_isbn, campo_modificado, valor_anterior, valor_nuevo, usuario)
        VALUES (OLD.ISBN, 'Dias_Prestamo', OLD.Dias_Prestamo, NEW.Dias_Prestamo, USER());
    END IF;

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_libro_auditoria_delete` AFTER DELETE ON `libro` FOR EACH ROW BEGIN
    -- Auditar la eliminación del libro
    INSERT INTO auditoria_libro (libro_isbn, campo_modificado, valor_anterior, valor_nuevo, usuario)
    VALUES (OLD.ISBN, 'ELIMINACION', CONCAT('Titulo: ', OLD.Titulo, ', Genero: ', OLD.Genero, ', Numero_Paginas: ', OLD.Numero_Paginas, ', Dias_Prestamo: ', OLD.Dias_Prestamo), 'REGISTRO ELIMINADO', USER());

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `prestamo`
--

CREATE TABLE `prestamo` (
  `Prestamo_id` varchar(255) NOT NULL,
  `Fecha_Prestamo` date NOT NULL,
  `Fecha_Devolucion` date NOT NULL,
  `Copia_Numero` int(255) NOT NULL,
  `Copia_ISBN` bigint(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `prestamo`
--

INSERT INTO `prestamo` (`Prestamo_id`, `Fecha_Prestamo`, `Fecha_Devolucion`, `Copia_Numero`, `Copia_ISBN`) VALUES
('pres1', '2023-01-15', '2023-01-20', 1, 1234567890),
('pres2', '2023-02-03', '2023-02-04', 2, 9999999999),
('pres3', '2023-04-09', '2023-04-11', 6, 2718281828),
('pres4', '2023-06-14', '2023-06-15', 9, 8888888888),
('pres5', '2023-07-02', '2023-07-09', 10, 5555555555),
('pres6', '2023-08-19', '2023-08-26', 12, 5555555555),
('pres7', '2023-10-24', '2023-10-27', 3, 1357924680);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `socio`
--

CREATE TABLE `socio` (
  `Numero` int(255) NOT NULL,
  `Nombre` varchar(255) NOT NULL,
  `Apellido` varchar(255) NOT NULL,
  `Direccion` varchar(255) NOT NULL,
  `Telefono` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `socio`
--

INSERT INTO `socio` (`Numero`, `Nombre`, `Apellido`, `Direccion`, `Telefono`) VALUES
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
(12, 'Sofia', 'Morales', 'Avenida del Mar 098, Costa Brava, Gijón', '5512345678');

--
-- Disparadores `socio`
--
DELIMITER $$
CREATE TRIGGER `auditoria_socio_delete` BEFORE DELETE ON `socio` FOR EACH ROW BEGIN
    INSERT INTO auditoria_socio_delete (

        operacion,
        nombre,
        direccion,
        telefono
    )
    VALUES (
        'DELETE',
        OLD.nombre,
        OLD.direccion,
        OLD.telefono
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `auditoria_socio_update` BEFORE UPDATE ON `socio` FOR EACH ROW BEGIN
    INSERT INTO auditoria_socio (
        operacion,
        antiguo_nombre,
        nuevo_nombre,
        antiguo_direccion,
        nueva_direccion,
        antiguo_telefono,
        nuevo_telefono
    )
    VALUES (
        'UPDATE',
        OLD.nombre,
        NEW.nombre,
        OLD.direccion,
        NEW.direccion,
        OLD.telefono,
        NEW.telefono
    );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_autores`
--

CREATE TABLE `tipo_autores` (
  `Copia_ISBN` bigint(255) NOT NULL,
  `Copia_Autor` int(255) NOT NULL,
  `Tipo_Autor` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipo_autores`
--

INSERT INTO `tipo_autores` (`Copia_ISBN`, `Copia_Autor`, `Tipo_Autor`) VALUES
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
-- Estructura Stand-in para la vista `vista_libros_autores`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_libros_autores` (
`ISBN` bigint(255)
,`Titulo` varchar(255)
,`Genero` varchar(255)
,`Numero_Paginas` int(255)
,`Dias_Prestamo` tinyint(255)
,`Autor_Apellido` varchar(255)
,`Autor_Nacimiento` date
,`Autor_Muerte` date
,`Tipo_Autor` varchar(255)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_prestamos_libros`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_prestamos_libros` (
`Prestamo_id` varchar(255)
,`Titulo` varchar(255)
,`Genero` varchar(255)
,`Fecha_Prestamo` date
,`Fecha_Devolucion` date
,`Socio_Nombre` varchar(255)
,`Socio_Apellido` varchar(255)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_libros_autores`
--
DROP TABLE IF EXISTS `vista_libros_autores`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_libros_autores`  AS SELECT `l`.`ISBN` AS `ISBN`, `l`.`Titulo` AS `Titulo`, `l`.`Genero` AS `Genero`, `l`.`Numero_Paginas` AS `Numero_Paginas`, `l`.`Dias_Prestamo` AS `Dias_Prestamo`, `a`.`Apellido` AS `Autor_Apellido`, `a`.`Nacimiento` AS `Autor_Nacimiento`, `a`.`Muerte` AS `Autor_Muerte`, `ta`.`Tipo_Autor` AS `Tipo_Autor` FROM ((`libro` `l` join `tipo_autores` `ta` on(`l`.`ISBN` = `ta`.`Copia_ISBN`)) join `autor` `a` on(`ta`.`Copia_Autor` = `a`.`Codigo`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_prestamos_libros`
--
DROP TABLE IF EXISTS `vista_prestamos_libros`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_prestamos_libros`  AS SELECT `p`.`Prestamo_id` AS `Prestamo_id`, `l`.`Titulo` AS `Titulo`, `l`.`Genero` AS `Genero`, `p`.`Fecha_Prestamo` AS `Fecha_Prestamo`, `p`.`Fecha_Devolucion` AS `Fecha_Devolucion`, `s`.`Nombre` AS `Socio_Nombre`, `s`.`Apellido` AS `Socio_Apellido` FROM ((`prestamo` `p` join `libro` `l` on(`p`.`Copia_ISBN` = `l`.`ISBN`)) join `socio` `s` on(`p`.`Copia_Numero` = `s`.`Numero`)) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `auditoria_autor`
--
ALTER TABLE `auditoria_autor`
  ADD PRIMARY KEY (`id_auditoria`);

--
-- Indices de la tabla `auditoria_libro`
--
ALTER TABLE `auditoria_libro`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `auditoria_socio`
--
ALTER TABLE `auditoria_socio`
  ADD PRIMARY KEY (`id_auditoria`);

--
-- Indices de la tabla `autor`
--
ALTER TABLE `autor`
  ADD PRIMARY KEY (`Codigo`);

--
-- Indices de la tabla `libro`
--
ALTER TABLE `libro`
  ADD PRIMARY KEY (`ISBN`),
  ADD KEY `index_Titulo` (`Titulo`);

--
-- Indices de la tabla `prestamo`
--
ALTER TABLE `prestamo`
  ADD PRIMARY KEY (`Prestamo_id`),
  ADD KEY `Copia_Numero` (`Copia_Numero`),
  ADD KEY `Copia_ISBN` (`Copia_ISBN`);

--
-- Indices de la tabla `socio`
--
ALTER TABLE `socio`
  ADD PRIMARY KEY (`Numero`);

--
-- Indices de la tabla `tipo_autores`
--
ALTER TABLE `tipo_autores`
  ADD KEY `Copia_ISBN` (`Copia_ISBN`),
  ADD KEY `Copia_Autor` (`Copia_Autor`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `auditoria_autor`
--
ALTER TABLE `auditoria_autor`
  MODIFY `id_auditoria` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auditoria_libro`
--
ALTER TABLE `auditoria_libro`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auditoria_socio`
--
ALTER TABLE `auditoria_socio`
  MODIFY `id_auditoria` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `prestamo`
--
ALTER TABLE `prestamo`
  ADD CONSTRAINT `Prestamo_ibfk_1` FOREIGN KEY (`Copia_Numero`) REFERENCES `socio` (`Numero`),
  ADD CONSTRAINT `Prestamo_ibfk_2` FOREIGN KEY (`Copia_ISBN`) REFERENCES `libro` (`ISBN`);

--
-- Filtros para la tabla `tipo_autores`
--
ALTER TABLE `tipo_autores`
  ADD CONSTRAINT `Tipo_Autores_ibfk_1` FOREIGN KEY (`Copia_ISBN`) REFERENCES `libro` (`ISBN`),
  ADD CONSTRAINT `Tipo_Autores_ibfk_2` FOREIGN KEY (`Copia_Autor`) REFERENCES `autor` (`Codigo`);

DELIMITER $$
--
-- Eventos
--
CREATE DEFINER=`root`@`localhost` EVENT `anual_eliminar_prestamos` ON SCHEDULE EVERY 1 YEAR STARTS '2024-08-08 13:54:53' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
DELETE FROM tbl_prestamo
WHERE pres_fechaDevolucion <= NOW() - INTERVAL 1 YEAR;
#datos menores a la fecha actual - 1 año
END$$

CREATE DEFINER=`root`@`localhost` EVENT `hora_eliminar_prestamos` ON SCHEDULE EVERY 1 HOUR STARTS '2024-08-08 13:54:53' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
DELETE FROM tbl_prestamo
WHERE pres_fechaDevolucion <= NOW() - INTERVAL 1 MONTH;
#datos menores a la fecha actual - 1 mes
END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
