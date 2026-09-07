USE Ventas_Tech_DB

-- ======================================================
-- PASO EXTRA: AGREGAR SEGMENTO Y TERRITORIO
-- ======================================================

-- 1. Segmento

ALTER TABLE clientes ADD segmento VARCHAR(50);

UPDATE clientes SET segmento = 'Ocasional' WHERE id_cliente IN (1, 3);
UPDATE clientes SET segmento = 'Regular' WHERE id_cliente IN (2, 4);
UPDATE clientes SET segmento = 'Nuevo' WHERE id_cliente = 5;

-- 2. Territorio

CREATE TABLE territorios (
    id_territorio INT PRIMARY KEY,
    region VARCHAR(50) NOT NULL,
    pais VARCHAR(50) NOT NULL,
    zona VARCHAR(50)
);

INSERT INTO territorios VALUES (1, 'AMBA', 'Argentina', 'Z1');
INSERT INTO territorios VALUES (2, 'NOA', 'Argentina', 'Z2');
INSERT INTO territorios VALUES (3, 'NEA', 'Argentina', 'Z3');
INSERT INTO territorios VALUES (4, 'Cuyo', 'Argentina', 'Z4');
INSERT INTO territorios VALUES (5, 'Centro', 'Argentina', 'Z5');
INSERT INTO territorios VALUES (6, 'Patagonia', 'Argentina', 'Z6');

ALTER TABLE ventas ADD id_territorio INT;

ALTER TABLE ventas ADD CONSTRAINT FK_ventas_territorio 
    FOREIGN KEY (id_territorio) REFERENCES territorios(id_territorio);

UPDATE dbo.ventas SET id_territorio = 1 WHERE id_cliente = 1;
UPDATE dbo.ventas SET id_territorio = 5 WHERE id_cliente = 2;
UPDATE dbo.ventas SET id_territorio = 5 WHERE id_cliente = 3;
UPDATE dbo.ventas SET id_territorio = 4 WHERE id_cliente = 4;
UPDATE dbo.ventas SET id_territorio = 2 WHERE id_cliente = 5;

SELECT * FROM clientes;
SELECT * FROM territorios;
SELECT * FROM ventas;

-- ======================================================
--	CONSULTA 1: VISTA BASE DEL PROYECTO
-- ======================================================

SELECT 
    v.fecha_venta AS fecha,
    v.id_cliente AS identificacion_cliente,
    c.nombre AS nombre_cliente,
    p.nombre_producto AS descripcion_producto,
    cat.nombre_categoria AS categoria_producto,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta,
    c.segmento AS segmento_cliente,
    t.region AS region,
    CASE WHEN v.id_cliente > 2 
        THEN 'Online' 
        ELSE 'Presencial' END AS canal
FROM dbo.ventas AS v
INNER JOIN dbo.clientes AS c ON v.id_cliente = c.id_cliente
INNER JOIN dbo.productos AS p ON v.id_producto = p.id_producto
INNER JOIN dbo.categorias AS cat ON p.id_categoria = cat.id_categoria
INNER JOIN dbo.territorios t ON v.id_territorio = t.id_territorio;

-- ======================================================
--	CONSULTA 2: CLIENTES SIN VENTAS
-- ======================================================

SELECT 
    c.nombre,
    c.email,
    c.fecha_registro
FROM dbo.clientes AS c
LEFT JOIN dbo.ventas AS v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;

-- ======================================================
--	CONSULTA 3: PRODUCTOS SIN VENTAS
-- ======================================================

SELECT 
    p.nombre_producto AS producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM dbo.productos AS p
INNER JOIN dbo.categorias AS cat ON p.id_categoria = cat.id_categoria
LEFT JOIN dbo.ventas AS v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;

-- ======================================================
--	CONSULTA 4: CONSOLIDADO POR CANAL
-- ======================================================

SELECT 
    canal,
    COUNT(*) AS cantidad_pedidos,
    SUM(total_venta) AS total_facturado
FROM (
    
    SELECT 
        fecha_venta,
        (cantidad * precio_unitario) AS total_venta,
        'Online' AS canal
    FROM dbo.ventas
    WHERE id_cliente > 2
    
    UNION ALL
    
    SELECT 
        fecha_venta,
        (cantidad * precio_unitario) AS total_venta,
        'Presencial' AS canal
    FROM dbo.ventas
    WHERE id_cliente < 3

) AS ventas_consolidadas
GROUP BY canal;

-- ===========================================================
-- COMENTARIOS Y HALLAZGOS
-- ===========================================================

-- 1. Se observa un registro completo de ventas, clientes y 
-- productos, sin registros faltantes.

-- 2. Todos los clientes registrados han realizado al menos
-- una compra.

-- 3. Todos los productos registrados han sido vendidos al 
-- menos una vez.

-- 4. Las ventas a través del canal Online registran un 50%
-- más de pedidos (6) que a través del Presencial (4), pero
-- tienen un volumen facturado similar.