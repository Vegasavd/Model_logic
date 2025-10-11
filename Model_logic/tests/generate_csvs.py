#!/usr/bin/env python3
"""
Generate realistic CSV test data for the Model_logic project.
Creates CSVs in tests/data/ for: tiendas, puesto_empleados, empleados, proveedores,
categoria_productos, productos, clientes, venta, detalles_venta.
Generates 3000 ventas and matching detalles_venta (avg 2 lines per venta).
"""
import argparse
import csv
import os
import random
from datetime import datetime, timedelta

# Allow overriding the output directory with CLI or environment variable
parser = argparse.ArgumentParser(description='Generate CSV test data')
parser.add_argument('--out-dir', dest='out_dir', help='Output directory for CSV files')
args = parser.parse_args()

default_out = os.path.join(os.path.dirname(__file__), 'data')
OUT_DIR = args.out_dir or os.environ.get('CSV_OUT_DIR') or default_out
OUT_DIR = os.path.abspath(OUT_DIR)
os.makedirs(OUT_DIR, exist_ok=True)

# Create a run-specific subfolder for easier management (e.g. tests/data/run_20251009_153000)
run_name = datetime.now().strftime('run_%Y%m%d_%H%M%S')
RUN_DIR = os.path.join(OUT_DIR, run_name)
os.makedirs(RUN_DIR, exist_ok=True)
random.seed(42)

now = datetime.now()

def iso(dt):
    return dt.strftime('%Y-%m-%d %H:%M:%S')

# Small helper pools
cities = ['Ciudad A', 'Ciudad B', 'Ciudad C', 'Ciudad D', 'Ciudad E']
first_names = ['Juan','Ana','Luis','Maria','Carlos','Jose','Lucia','Miguel','Sofia','Diego','Laura','Pedro','Marta']
last_names = ['Perez','Gomez','Lopez','Martinez','Rodriguez','Garcia','Hernandez','Sanchez','Ramirez']
company_words = ['Comercial','Suministros','Distribuciones','Servicios','Importaciones','Soluciones']
product_adjectives = ['Pro','Max','Lite','Plus','X','S']
product_nouns = ['Telefono','Auricular','Tablet','Monitor','Teclado','Cargador','Bateria']

# 1) tiendas
N_TIENDA = 5
tiendas = []
for i in range(1, N_TIENDA+1):
    tiendas.append({
        'id_tienda': i,
        'nombre': f'Tienda {i}',
        'direccion': f'Calle {100+i} Avenida {i}',
        'telefono': f'555-10{str(i).zfill(2)}',
        'ciudad': random.choice(cities),
        'created_at': iso(now - timedelta(days=random.randint(30,365))),
        'updated_at': iso(now - timedelta(days=random.randint(0,29)))
    })

with open(os.path.join(RUN_DIR, 'tiendas.csv'), 'w', newline='', encoding='utf-8') as f:
    w = csv.DictWriter(f, fieldnames=['id_tienda','nombre','direccion','telefono','ciudad','created_at','updated_at'])
    w.writeheader()
    w.writerows(tiendas)

# 2) puesto_empleados
puestos = []
puesto_names = ['Vendedor','Cajero','Gerente','Repositor','Atencion Cliente']
for i, name in enumerate(puesto_names, start=1):
    puestos.append({'id_puesto': i, 'nombre_puesto': name, 'created_at': iso(now - timedelta(days=400)), 'updated_at': iso(now - timedelta(days=10))})
with open(os.path.join(RUN_DIR, 'puesto_empleados.csv'), 'w', newline='', encoding='utf-8') as f:
    w = csv.DictWriter(f, fieldnames=['id_puesto','nombre_puesto','created_at','updated_at'])
    w.writeheader(); w.writerows(puestos)

# 3) empleados
N_EMPLEADOS = 100
empleados = []
for i in range(1, N_EMPLEADOS+1):
    fn = random.choice(first_names)
    ln = random.choice(last_names)
    empleados.append({
        'id_empleado': i,
        'nombre': fn,
        'apellido_paterno': ln,
        'apellido_materno': random.choice(last_names),
        'rfc': f'RFC{random.randint(100000,999999)}',
        'fecha_contratacion': (now - timedelta(days=random.randint(30,2000))).date().isoformat(),
        'id_tienda': random.randint(1, N_TIENDA),
        'id_puesto': random.randint(1, len(puesto_names)),
        'created_at': iso(now - timedelta(days=random.randint(30,365))),
        'updated_at': iso(now - timedelta(days=random.randint(0,29)))
    })
with open(os.path.join(RUN_DIR, 'empleados.csv'), 'w', newline='', encoding='utf-8') as f:
    w = csv.DictWriter(f, fieldnames=['id_empleado','nombre','apellido_paterno','apellido_materno','rfc','fecha_contratacion','id_tienda','id_puesto','created_at','updated_at'])
    w.writeheader(); w.writerows(empleados)

# 4) proveedores
N_PROVE = 10
proveedores = []
for i in range(1, N_PROVE+1):
    proveedores.append({
        'id_proveedor': i,
        'nombre_empresa': f'{random.choice(company_words)} {i}',
        'contacto_nombre': f'{random.choice(first_names)} {random.choice(last_names)}',
        'contacto_email': f'contacto{i}@proveedor{i}.com',
        'contacto_telefono': f'555-20{str(i).zfill(2)}',
        'created_at': iso(now - timedelta(days=random.randint(100,800))),
        'updated_at': iso(now - timedelta(days=random.randint(0,30)))
    })
with open(os.path.join(RUN_DIR, 'proveedores.csv'), 'w', newline='', encoding='utf-8') as f:
    w = csv.DictWriter(f, fieldnames=['id_proveedor','nombre_empresa','contacto_nombre','contacto_email','contacto_telefono','created_at','updated_at'])
    w.writeheader(); w.writerows(proveedores)

# 5) categoria_productos
N_CAT = 6
cats = []
for i in range(1, N_CAT+1):
    cats.append({'id_categoria': i, 'nombre_categoria': f'Categoria {i}', 'descripcion': f'Descripcion categoria {i}','created_at': iso(now - timedelta(days=500)),'updated_at': iso(now - timedelta(days=10))})
with open(os.path.join(RUN_DIR, 'categoria_productos.csv'), 'w', newline='', encoding='utf-8') as f:
    w = csv.DictWriter(f, fieldnames=['id_categoria','nombre_categoria','descripcion','created_at','updated_at'])
    w.writeheader(); w.writerows(cats)

# 6) productos
N_PRODUCTOS = 200
productos = []
for i in range(1, N_PRODUCTOS+1):
    name = f"{random.choice(product_nouns)} {random.choice(product_adjectives)} {random.randint(1,999)}"
    precio = round(random.uniform(10.0, 1500.0), 2)
    costo = round(precio * random.uniform(0.5, 0.85), 2)
    productos.append({
        'id_producto': i,
        'sku': f'SKU-{str(i).zfill(4)}',
        'nombre_producto': name,
        'descripcion': f'Descripcion de {name}',
        'precio_venta': f"{precio:.2f}",
        'costo_compra': f"{costo:.2f}",
        'id_categoria': random.randint(1, N_CAT),
        'id_proveedor': random.randint(1, N_PROVE),
        'created_at': iso(now - timedelta(days=random.randint(30,365))),
        'updated_at': iso(now - timedelta(days=random.randint(0,29)))
    })
with open(os.path.join(RUN_DIR, 'productos.csv'), 'w', newline='', encoding='utf-8') as f:
    w = csv.DictWriter(f, fieldnames=['id_producto','sku','nombre_producto','descripcion','precio_venta','costo_compra','id_categoria','id_proveedor','created_at','updated_at'])
    w.writeheader(); w.writerows(productos)

# 7) clientes
N_CLIENTES = 1200
clientes = []
for i in range(1, N_CLIENTES+1):
    fn = random.choice(first_names)
    ln = random.choice(last_names)
    clientes.append({
        'id_cliente': i,
        'nombre': f'{fn} {ln}',
        'rfc': f'RFC{random.randint(10000,99999)}',
        'email': f'{fn.lower()}.{ln.lower()}{i}@example.com',
        'telefono': f'555-30{str(i%100).zfill(2)}',
        'created_at': iso(now - timedelta(days=random.randint(10,2000))),
        'updated_at': iso(now - timedelta(days=random.randint(0,30)))
    })
with open(os.path.join(RUN_DIR, 'clientes.csv'), 'w', newline='', encoding='utf-8') as f:
    w = csv.DictWriter(f, fieldnames=['id_cliente','nombre','rfc','email','telefono','created_at','updated_at'])
    w.writeheader(); w.writerows(clientes)

# 8) venta + detalles_venta
N_VENTAS = 3000
venta_rows = []
detalle_rows = []
detalle_id = 1

for vid in range(1, N_VENTAS+1):
    # fecha distributed in last 365 days
    fecha = now - timedelta(days=random.randint(0,365), hours=random.randint(0,23), minutes=random.randint(0,59))
    cliente_id = random.randint(1, N_CLIENTES)
    empleado_id = random.randint(1, N_EMPLEADOS)
    tienda_id = random.randint(1, N_TIENDA)

    # decide number of lines
    n_lines = random.choices([1,2,3,4], weights=[50,30,15,5])[0]
    monto_total = 0.0
    for _ in range(n_lines):
        producto = random.choice(productos)
        cantidad = random.choices([1,2,3,4,5], weights=[60,20,10,7,3])[0]
        precio = float(producto['precio_venta'])
        subtotal = round(cantidad * precio, 2)
        monto_total += subtotal
        detalle_rows.append({
            'id_detalle_venta': detalle_id,
            'id_venta': vid,
            'id_producto': producto['id_producto'],
            'cantidad': cantidad,
            'precio_unitario': f"{precio:.2f}",
            'subtotal': f"{subtotal:.2f}",
            'created_at': iso(fecha),
            'updated_at': iso(fecha)
        })
        detalle_id += 1

    venta_rows.append({
        'id_venta': vid,
        'fecha_hora': iso(fecha),
        'monto_total': f"{monto_total:.2f}",
        'id_cliente': cliente_id,
        'id_empleado': empleado_id,
        'id_tienda': tienda_id,
        'created_at': iso(fecha),
        'updated_at': iso(fecha)
    })

with open(os.path.join(RUN_DIR, 'venta.csv'), 'w', newline='', encoding='utf-8') as f:
    w = csv.DictWriter(f, fieldnames=['id_venta','fecha_hora','monto_total','id_cliente','id_empleado','id_tienda','created_at','updated_at'])
    w.writeheader(); w.writerows(venta_rows)

with open(os.path.join(RUN_DIR, 'detalles_venta.csv'), 'w', newline='', encoding='utf-8') as f:
    w = csv.DictWriter(f, fieldnames=['id_detalle_venta','id_venta','id_producto','cantidad','precio_unitario','subtotal','created_at','updated_at'])
    w.writeheader(); w.writerows(detalle_rows)

# 9) inventario - create stock rows for some product-store pairs
inventario_rows = []
for t in tiendas:
    for p in productos:
        # 40% chance to have a stock row for a given product in a store
        if random.random() < 0.40:
            qty = random.randint(0, 100)
            inventario_rows.append({
                'id_tienda': t['id_tienda'],
                'id_producto': p['id_producto'],
                'cantidad': qty,
                'fecha_ultima_actualizacion': iso(now - timedelta(days=random.randint(0,90))),
                'updated_at': iso(now - timedelta(days=random.randint(0,90)))
            })

with open(os.path.join(RUN_DIR, 'inventario.csv'), 'w', newline='', encoding='utf-8') as f:
    w = csv.DictWriter(f, fieldnames=['id_tienda','id_producto','cantidad','fecha_ultima_actualizacion','updated_at'])
    w.writeheader(); w.writerows(inventario_rows)

# 10) facturacion - create invoices for a subset of ventas
factura_rows = []
fid = 1
for v in venta_rows:
    # generate invoices for ~70% of sales
    if random.random() < 0.70:
        factura_rows.append({
            'id_factura': fid,
            'id_venta': v['id_venta'],
            'serie': random.choice(['A','B','C']),
            'folio': str(1000 + fid),
            'fecha_emision': v['fecha_hora'],
            'total': v['monto_total'],
            'metodo_pago': random.choice(['Efectivo','Tarjeta','Transferencia']),
            'estado': 'emitida',
            'xml_path': '',
            'pdf_path': '',
            'created_at': v['created_at'],
            'updated_at': v['updated_at']
        })
        fid += 1

with open(os.path.join(RUN_DIR, 'facturacion.csv'), 'w', newline='', encoding='utf-8') as f:
    w = csv.DictWriter(f, fieldnames=['id_factura','id_venta','serie','folio','fecha_emision','total','metodo_pago','estado','xml_path','pdf_path','created_at','updated_at'])
    w.writeheader(); w.writerows(factura_rows)

# 11+12) compra and compra_producto
N_COMPRAS = 200
compra_rows = []
compra_producto_rows = []
cpid = 1
for cid in range(1, N_COMPRAS+1):
    proveedor = random.choice(proveedores)
    tienda = random.choice(tiendas)
    fecha_compra = iso(now - timedelta(days=random.randint(0,365)))
    n_lines = random.choices([1,2,3], weights=[60,30,10])[0]
    total_compra = 0.0
    for _ in range(n_lines):
        prod = random.choice(productos)
        cantidad = random.randint(1,50)
        precio = float(prod['costo_compra'])
        subtotal = round(cantidad * precio, 2)
        total_compra += subtotal
        compra_producto_rows.append({
            'id_compra_producto': cpid,
            'id_compra': cid,
            'id_producto': prod['id_producto'],
            'id_tienda': tienda['id_tienda'],
            'cantidad': cantidad,
            'precio_unitario': f"{precio:.2f}",
            'subtotal': f"{subtotal:.2f}",
            'created_at': fecha_compra,
            'updated_at': fecha_compra
        })
        cpid += 1
    recibida = random.random() < 0.6
    aplicada = recibida
    compra_rows.append({
        'id_compra': cid,
        'fecha_compra': fecha_compra,
        'id_proveedor': proveedor['id_proveedor'],
        'id_tienda': tienda['id_tienda'],
        'total_compra': f"{total_compra:.2f}",
        'estado': 'pendiente' if not recibida else 'recibida',
        'recibida': str(recibida),
        'aplicada': str(aplicada),
        'fecha_recepcion': fecha_compra if recibida else '',
        'created_at': fecha_compra,
        'updated_at': fecha_compra
    })

with open(os.path.join(RUN_DIR, 'compra.csv'), 'w', newline='', encoding='utf-8') as f:
    w = csv.DictWriter(f, fieldnames=['id_compra','fecha_compra','id_proveedor','id_tienda','total_compra','estado','recibida','aplicada','fecha_recepcion','created_at','updated_at'])
    w.writeheader(); w.writerows(compra_rows)

with open(os.path.join(RUN_DIR, 'compra_producto.csv'), 'w', newline='', encoding='utf-8') as f:
    w = csv.DictWriter(f, fieldnames=['id_compra_producto','id_compra','id_producto','id_tienda','cantidad','precio_unitario','subtotal','created_at','updated_at'])
    w.writeheader(); w.writerows(compra_producto_rows)

# Summary
print('Wrote CSVs to', RUN_DIR)
print('Base output folder:', OUT_DIR)
print('To change output folder, run: python tests\\generate_csvs.py --out-dir path\\to\\folder')
print('Counts: tiendas=%d, puestos=%d, empleados=%d, proveedores=%d, categorias=%d, productos=%d, clientes=%d, ventas=%d, detalles=%d, inventario=%d, facturas=%d, compras=%d, compra_lineas=%d' % (
    len(tiendas), len(puestos), len(empleados), len(proveedores), len(cats), len(productos), len(clientes), len(venta_rows), len(detalle_rows), len(inventario_rows), len(factura_rows), len(compra_rows), len(compra_producto_rows)
))
