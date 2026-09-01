USE Ventas_Tech_DB

-- ======================================================
--	CONSULTA 1: RESUMEN EJECUTIVO MENSUAL
-- ======================================================

SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(id_venta) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) / COUNT(id_venta) AS ticket_promedio
FROM dbo.ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes

-- ===========================================================
--	CONSULTA 2: RANKING DE PRODUCTOS
-- ===========================================================

SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado
FROM dbo.ventas
GROUP BY id_producto
ORDER BY total_generado DESC;

-- ===========================================================
--	CONSULTA 3: CLIENTES RECURRENTES
-- ===========================================================

SELECT 
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM dbo.ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;

-- ===========================================================
--	CONSULTA 4: MESES POR ENCIMA/POR DEBAJO DEL PROMEDIO
-- ===========================================================

SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    CASE 
        WHEN SUM(cantidad * precio_unitario) >= (
            SELECT AVG(total) FROM (
                SELECT SUM(cantidad * precio_unitario) AS total 
                FROM ventas 
                GROUP BY MONTH(fecha_venta)
            ) AS promedio_general_mensual
        ) THEN 'Por encima'
        ELSE 'Por debajo' END AS relacion_con_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

-- ===========================================================
-- BLOQUE DE CIERRE
-- ===========================================================

-- 1. El id_producto 1 es la principal fuente de ingresos
-- del mes: representa el 55% ($3.600,00) de la facturación 
-- total ($6.444,00) del período.

-- 2. El id_producto 2 tuvo la mayor cantidad de unidades
-- vendidas (13 unidades) en el mes, pero es el que menos 
-- aporta a la facturación total del período (5,6%).

-- 3. Todos los clientes registrados realizaron 2 pedidos
-- cada uno, pero el 73.5% de la facturación total está 
-- concentrado en los clientes 1 ($2.640,00) y 5 ($2.100.00).
