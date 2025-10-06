-- Script de prueba para validar triggers y la tabla `facturacion`
-- Ejecutar ESTE ARCHIVO después de aplicar `modelo_logico.sql` en la BD de prueba

-- Inserciones básicas de referencia
INSERT INTO tiendas (nombre, direccion, telefono, ciudad) VALUES ('Tienda Central', 'Calle Falsa 123', '555-0001', 'Ciudad A');
INSERT INTO puesto_empleados (nombre_puesto) VALUES ('Vendedor');
INSERT INTO empleados (nombre, apellido_paterno, apellido_materno, rfc, fecha_contratacion, id_tienda, id_puesto)
VALUES ('Ana', 'Gomez', 'Perez', 'GMPA900101', '2020-01-10', 1, 1);

INSERT INTO proveedores (nombre_empresa, contacto_nombre, contacto_email, contacto_telefono)
VALUES ('Proveedor A', 'Carlos Ruiz', 'carlos@prov.com', '555-1000');

INSERT INTO categoria_productos (nombre_categoria, descripcion) VALUES ('Electronica', 'Aparatos electronicos');

INSERT INTO productos (sku, nombre_producto, descripcion, precio_venta, costo_compra, id_categoria, id_proveedor)
VALUES ('SKU-001', 'Telefono X', 'Telefono inteligente', 199.99, 120.00, 1, 1);

INSERT INTO clientes (nombre, rfc, email, telefono) VALUES ('Juan Perez', 'JPR900101XXX', 'juan@example.com', '555-2000');

-- Crear una venta (encabezado) - monto_total inicial 0, trigger debe actualizarlo tras insertar detalles
INSERT INTO venta (id_cliente, id_empleado, id_tienda) VALUES (1,1,1);

-- Insertar detalles de venta usando la venta recien creada (obtenemos el id mas reciente)
INSERT INTO detalles_venta (id_venta, id_producto, cantidad, precio_unitario)
VALUES ((SELECT id_venta FROM venta ORDER BY id_venta DESC LIMIT 1), 1, 2, 199.99),
        ((SELECT id_venta FROM venta ORDER BY id_venta DESC LIMIT 1), 1, 1, 199.99);

-- Esperamos que el trigger haya actualizado venta.monto_total
-- Mostrar venta y detalles
SELECT * FROM venta ORDER BY id_venta DESC LIMIT 1;
SELECT * FROM detalles_venta WHERE id_venta = (SELECT id_venta FROM venta ORDER BY id_venta DESC LIMIT 1);

-- Insertar factura (facturacion) referenciando la venta
INSERT INTO facturacion (id_venta, serie, folio, total, metodo_pago)
VALUES ((SELECT id_venta FROM venta ORDER BY id_venta DESC LIMIT 1), 'A', '0001',
        (SELECT monto_total FROM venta WHERE id_venta = (SELECT id_venta FROM venta ORDER BY id_venta DESC LIMIT 1)), 'tarjeta');

-- Mostrar facturacion
SELECT * FROM facturacion WHERE id_venta = (SELECT id_venta FROM venta ORDER BY id_venta DESC LIMIT 1);

-- Comprobaciones rapidas
-- 1) monto_total = SUM(subtotal) de detalles_venta
SELECT v.id_venta, v.monto_total, COALESCE(SUM(d.subtotal),0) AS suma_subtotales
FROM venta v
LEFT JOIN detalles_venta d ON d.id_venta = v.id_venta
WHERE v.id_venta = (SELECT id_venta FROM venta ORDER BY id_venta DESC LIMIT 1)
GROUP BY v.id_venta, v.monto_total;

-- 2) facturacion existe y total coincide
SELECT f.id_factura, f.id_venta, f.total, v.monto_total
FROM facturacion f
JOIN venta v ON v.id_venta = f.id_venta
WHERE f.id_venta = (SELECT id_venta FROM venta ORDER BY id_venta DESC LIMIT 1);

-- FIN
