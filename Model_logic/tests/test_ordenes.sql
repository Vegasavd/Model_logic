-- Pruebas deterministas para órdenes (ventas y compras)
-- Usa INSERT ... RETURNING y bloques PL/pgSQL para capturar ids y validar montos e inventario
-- Ejecutar tras aplicar `modelo_logico.sql` en la BD de prueba

DO $$
DECLARE
	v_tienda INT;
	v_puesto INT;
	v_empleado INT;
	v_proveedor INT;
	v_categoria INT;
	v_producto INT;
	v_cliente INT;
	v_venta INT;
	v_compra INT;
	v_num NUMERIC;
	suma NUMERIC;
	expected_qty INT;
BEGIN
	-- Referencias base (deterministas y coherentes)
	INSERT INTO tiendas (nombre, direccion, telefono, ciudad)
	VALUES ('Tienda Norte', 'Av. Principal 100', '555-0100', 'Ciudad B')
	RETURNING id_tienda INTO v_tienda;

	INSERT INTO puesto_empleados (nombre_puesto)
	VALUES ('Cajero')
	RETURNING id_puesto INTO v_puesto;

	INSERT INTO empleados (nombre, apellido_paterno, apellido_materno, rfc, fecha_contratacion, id_tienda, id_puesto)
	VALUES ('Luis', 'Martinez', 'Sanchez', 'LMS800202XXX', '2019-06-01', v_tienda, v_puesto)
	RETURNING id_empleado INTO v_empleado;

	INSERT INTO proveedores (nombre_empresa, contacto_nombre, contacto_email, contacto_telefono)
	VALUES ('Distribuciones Norte S.A.', 'Mariana Lopez', 'mariana@distnorte.com', '555-1100')
	RETURNING id_proveedor INTO v_proveedor;

	INSERT INTO categoria_productos (nombre_categoria, descripcion)
	VALUES ('Hogar', 'Electrodomésticos y artículos para el hogar')
	RETURNING id_categoria INTO v_categoria;

	INSERT INTO productos (sku, nombre_producto, descripcion, precio_venta, costo_compra, id_categoria, id_proveedor)
	VALUES ('SKU-100', 'Licuadora Turbo', 'Licuadora 1.5L, 600W', 749.00, 450.00, v_categoria, v_proveedor)
	RETURNING id_producto INTO v_producto;

	INSERT INTO clientes (nombre, rfc, email, telefono)
	VALUES ('Marcos Rivera', 'MRV900101ABC', 'marcos.rivera@example.com', '555-2200')
	RETURNING id_cliente INTO v_cliente;

	-- Asegurar inventario inicial: 5 unidades
	INSERT INTO inventario (id_tienda, id_producto, cantidad)
	VALUES (v_tienda, v_producto, 5)
	ON CONFLICT (id_tienda, id_producto) DO UPDATE SET cantidad = EXCLUDED.cantidad, fecha_ultima_actualizacion = now(), updated_at = now();

	-- ---------------------
	-- Prueba: Venta con detalles
	-- ---------------------
	INSERT INTO venta (id_cliente, id_empleado, id_tienda, fecha_hora)
	VALUES (v_cliente, v_empleado, v_tienda, '2025-10-08 10:00:00')
	RETURNING id_venta INTO v_venta;

	-- Insertar dos líneas de venta (1 unidad y 2 unidades) con precio unitario igual al precio_venta
	INSERT INTO detalles_venta (id_venta, id_producto, cantidad, precio_unitario)
	VALUES (v_venta, v_producto, 1, 749.00), (v_venta, v_producto, 2, 749.00);

	-- Validar que el trigger haya actualizado el monto_total de la venta
	SELECT monto_total INTO v_num FROM venta WHERE id_venta = v_venta;
	SELECT COALESCE(SUM(subtotal),0) INTO suma FROM detalles_venta WHERE id_venta = v_venta;
	IF v_num IS DISTINCT FROM suma THEN
		RAISE EXCEPTION 'ASSERT FAILED (venta): monto_total (%) != SUM(subtotal) (%) for id_venta=%', v_num, suma, v_venta;
	END IF;

	-- Insertar factura consistente con la venta (uso del monto calculado)
	INSERT INTO facturacion (id_venta, serie, folio, total, metodo_pago)
	VALUES (v_venta, 'B', '2025-0001', v_num, 'efectivo');

	-- ---------------------
	-- Prueba: Compra y aplicación a inventario
	-- ---------------------
	INSERT INTO compra (id_proveedor, id_tienda, fecha_compra)
	VALUES (v_proveedor, v_tienda, '2025-10-07 09:00:00')
	RETURNING id_compra INTO v_compra;

	-- Insertar líneas de compra: 10 unidades a 450.00 y 5 unidades a 430.00
	INSERT INTO compra_producto (id_compra, id_producto, cantidad, precio_unitario)
	VALUES (v_compra, v_producto, 10, 450.00), (v_compra, v_producto, 5, 430.00);

	-- Validar total_compra calculado por trigger
	SELECT total_compra INTO v_num FROM compra WHERE id_compra = v_compra;
	SELECT COALESCE(SUM(subtotal),0) INTO suma FROM compra_producto WHERE id_compra = v_compra;
	IF v_num IS DISTINCT FROM suma THEN
		RAISE EXCEPTION 'ASSERT FAILED (compra): total_compra (%) != SUM(subtotal) (%) for id_compra=%', v_num, suma, v_compra;
	END IF;

	-- Inventario antes de recibir la compra
	SELECT cantidad INTO expected_qty FROM inventario WHERE id_tienda = v_tienda AND id_producto = v_producto;
	IF expected_qty IS NULL THEN
		expected_qty := 0;
	END IF;

	-- Marcar compra como recibida: trigger debe aplicar +15 unidades
	UPDATE compra SET recibida = TRUE WHERE id_compra = v_compra;

	-- Verificar que inventario aumentó en 15
	SELECT cantidad INTO v_num FROM inventario WHERE id_tienda = v_tienda AND id_producto = v_producto;
	IF v_num IS NULL THEN
		RAISE EXCEPTION 'ASSERT FAILED (inventario): fila inexistente tras recepción para tienda=% producto=%', v_tienda, v_producto;
	END IF;
	IF v_num <> (expected_qty + 15) THEN
		RAISE EXCEPTION 'ASSERT FAILED (inventario cantidad): actual (%) != esperado (%) after compra=%', v_num, (expected_qty + 15), v_compra;
	END IF;

	-- Reaplicar recibida (idempotencia): no debe cambiar la cantidad
	UPDATE compra SET recibida = TRUE WHERE id_compra = v_compra;
	SELECT cantidad INTO v_num FROM inventario WHERE id_tienda = v_tienda AND id_producto = v_producto;
	IF v_num <> (expected_qty + 15) THEN
		RAISE EXCEPTION 'ASSERT FAILED (idempotencia): inventario cambiado tras re-aplicar recibida for compra=%', v_compra;
	END IF;

END
$$;

-- Fin de pruebas deterministas para órdenes

