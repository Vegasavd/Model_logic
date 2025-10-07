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

-- Asserts automáticos: validar que monto_total coincide con sum(subtotal)
DO $$
DECLARE
        v_total NUMERIC;
        s_total NUMERIC;
        vid INT := (SELECT id_venta FROM venta ORDER BY id_venta DESC LIMIT 1);
BEGIN
        SELECT monto_total INTO v_total FROM venta WHERE id_venta = vid;
        SELECT COALESCE(SUM(subtotal),0) INTO s_total FROM detalles_venta WHERE id_venta = vid;
        IF v_total IS DISTINCT FROM s_total THEN
                RAISE EXCEPTION 'ASSERT FAILED: venta.monto_total (%) != SUM(detalles_venta.subtotal) (%) for id_venta=%', v_total, s_total, vid;
        END IF;
END
$$;

-- Asserts: facturacion.total == venta.monto_total
DO $$
DECLARE
        v_total NUMERIC;
        f_total NUMERIC;
        vid INT := (SELECT id_venta FROM venta ORDER BY id_venta DESC LIMIT 1);
BEGIN
        SELECT monto_total INTO v_total FROM venta WHERE id_venta = vid;
        SELECT total INTO f_total FROM facturacion WHERE id_venta = vid LIMIT 1;
        IF v_total IS DISTINCT FROM f_total THEN
                RAISE EXCEPTION 'ASSERT FAILED: facturacion.total (%) != venta.monto_total (%) for id_venta=%', f_total, v_total, vid;
        END IF;
END
$$;

-- FIN

-- -----------------------------------------------------------------
-- Pruebas de Compras -> validar cálculo de total_compra y aplicación a inventario
-- -----------------------------------------------------------------

-- Mostrar inventario inicial para el producto 1 en la tienda 1 (debe existir fila o no)
SELECT * FROM inventario WHERE id_tienda = 1 AND id_producto = 1;

-- Insertar una compra en estado pendiente
INSERT INTO compra (id_proveedor, id_tienda)
VALUES (1, 1);

-- Insertar líneas de compra
INSERT INTO compra_producto (id_compra, id_producto, cantidad, precio_unitario)
VALUES ((SELECT id_compra FROM compra ORDER BY id_compra DESC LIMIT 1), 1, 10, 100.00),
((SELECT id_compra FROM compra ORDER BY id_compra DESC LIMIT 1), 1, 5, 95.00);

-- Ver total_compra (trigger debe haberlo calculado)
SELECT id_compra, total_compra FROM compra ORDER BY id_compra DESC LIMIT 1;

-- Assert: compra.total_compra == SUM(compra_producto.subtotal)
DO $$
DECLARE
        cid INT := (SELECT id_compra FROM compra ORDER BY id_compra DESC LIMIT 1);
        tc NUMERIC;
        ssum NUMERIC;
BEGIN
        SELECT total_compra INTO tc FROM compra WHERE id_compra = cid;
        SELECT COALESCE(SUM(subtotal),0) INTO ssum FROM compra_producto WHERE id_compra = cid;
        IF tc IS DISTINCT FROM ssum THEN
                RAISE EXCEPTION 'ASSERT FAILED: compra.total_compra (%) != SUM(compra_producto.subtotal) (%) for id_compra=%', tc, ssum, cid;
        END IF;
END
$$;

-- Inventario debe seguir igual (compra aún no recibida)
SELECT * FROM inventario WHERE id_tienda = 1 AND id_producto = 1;

-- Marcar compra como recibida (trigger aplicará las líneas al inventario)
UPDATE compra SET recibida = TRUE WHERE id_compra = (SELECT id_compra FROM compra ORDER BY id_compra DESC LIMIT 1);

-- Revisar compra (fecha_recepcion) y total
SELECT id_compra, recibida, fecha_recepcion, total_compra FROM compra ORDER BY id_compra DESC LIMIT 1;

-- Ver inventario después de recepción: cantidad debe incrementarse en 15
SELECT * FROM inventario WHERE id_tienda = 1 AND id_producto = 1;

-- Comprobación automática: la cantidad en inventario debe ser igual a la suma de cantidades compradas (idempotente)
DO $$
DECLARE
        cid INT := (SELECT id_compra FROM compra ORDER BY id_compra DESC LIMIT 1);
        tienda INT;
        producto INT;
        expected_qty INT;
        qty_before INT;
        qty_after INT;
BEGIN
        SELECT id_tienda INTO tienda FROM compra WHERE id_compra = cid;
        SELECT id_producto INTO producto FROM compra_producto WHERE id_compra = cid ORDER BY id_compra_producto LIMIT 1;
        SELECT COALESCE(SUM(cantidad),0) INTO expected_qty FROM compra_producto WHERE id_compra = cid;

        -- obtener cantidad actual (después de la primera recepción)
        SELECT cantidad INTO qty_before FROM inventario WHERE id_tienda = tienda AND id_producto = producto;
        IF qty_before IS NULL THEN
                RAISE EXCEPTION 'ASSERT FAILED: inventario row missing for tienda=% producto=% (expected %)', tienda, producto, expected_qty;
        END IF;
        IF qty_before IS DISTINCT FROM expected_qty THEN
                RAISE EXCEPTION 'ASSERT FAILED: inventario.cantidad (%) != expected (%) after reception for compra=%', qty_before, expected_qty, cid;
        END IF;

        -- Re-emitir la marca de recibida: no debe cambiar la cantidad (idempotencia)
        UPDATE compra SET recibida = TRUE WHERE id_compra = cid;

        SELECT cantidad INTO qty_after FROM inventario WHERE id_tienda = tienda AND id_producto = producto;
        IF qty_after IS DISTINCT FROM qty_before THEN
                RAISE EXCEPTION 'ASSERT FAILED: Idempotency violated, qty changed from % to % for compra=%', qty_before, qty_after, cid;
        END IF;
END
$$;

-- FIN PRUEBAS DE COMPRA
