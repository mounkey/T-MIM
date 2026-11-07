WikiArticle.where(is_global: true).destroy_all

articles = [
  {
    title: 'Guía 01: Puesta en Marcha y Configuración Inicial',
    category: 'Primeros Pasos en T-MIM',
    position: 1,
    icon: 'fa-play-circle',
    content: "BIENVENIDO A T-MIM (Talleres y Mantención Inteligente)
======================================================
Esta guía le orientará en los primeros 10 minutos para dejar su taller mecánico 100% operativo.

1. CONFIGURACIÓN DEL PERFIL DEL TALLER:
----------------------------------------
- Vaya al menú superior o 'Configuración'.
- Verifique que el Nombre Comercial, RUT y Teléfono de contacto estén correctos.
- Estos datos aparecerán impresos automáticamente en los presupuestos y comprobantes de entrega PDF para sus clientes.

2. ASIGNACIÓN DE USUARIOS Y MECÁNICOS:
----------------------------------------
- En el menú 'Configuración -> Acceso -> Usuarios', puede crear cuentas para sus mecánicos o recepcionistas.
- Cada intervención que se registre en la bitácora o bodega quedará firmada con el nombre del usuario responsable para auditoría interna.

3. CATEGORÍAS DE VEHÍCULOS:
----------------------------------------
- En 'Configuración -> Vehículos -> Categorías', cree los tipos de vehículos que atiende su taller (Ej: Autos particulares, Camionetas 4x4, Motos Scooter, Motos Enduro).
- Esto le permitirá filtrar reportes y consumos de bodega con mayor orden."
  },
  {
    title: 'Guía 02: Recepción de Clientes y Flota de Vehículos',
    category: 'Operaciones de Taller',
    position: 2,
    icon: 'fa-car',
    content: "RECEPCIÓN DE CLIENTES Y CONTROL DE VEHÍCULOS
======================================================
El corazón operativo de T-MIM es el historial clínico por patente o número de motor/chasis.

1. REGISTRO DE UN NUEVO VEHÍCULO:
----------------------------------------
- Ingrese al módulo 'Vehículos' desde el menú lateral.
- Haga clic en '+ Nuevo Vehículo'.
- Ingrese la Patente (o Chasis en motos nuevas), Marca, Modelo, Año y asigne o cree el Cliente titular.

2. CÓMO FUNCIONA EL TOPE MENSUAL DE VEHÍCULOS (CAPACIDAD):
----------------------------------------
- Su plan contratado contempla un límite mensual de vehículos atendidos (Ej: 50 en Plan Inicial/Estándar, 150 en Pro, 300 en Full).
- En el Dashboard principal verá la barra de progreso en tiempo real:
  * Verde (0-89%): Operación normal.
  * Amarillo (90-99%): Alerta preventiva (al 95% el sistema le envía un correo para avisar que quedan pocos cupos).
  * Rojo (100%): Tope alcanzado. Se bloquea temporalmente la creación de nuevos vehículos.
- Si en días de alta demanda supera el cupo, puede adquirir bolsas inmediatas de +20 o +50 vehículos contactando al soporte de T-MIM."
  },
  {
    title: 'Guía 03: Control de Bodega, Repuestos y Kardex',
    category: 'Repuestos & Kardex',
    position: 3,
    icon: 'fa-boxes',
    content: "CONTROL DE BODEGA E INVENTARIO EN EL TALLER
======================================================
(Disponible en Plan Estándar, Plan Pro y Plan Full)

1. DAR DE ALTA UN REPUESTO O INSUMO:
----------------------------------------
- Vaya a 'Bodega -> Repuestos'.
- Ingrese Nombre (Ej: 'Filtro de Aceite Mann W712/52'), Código/SKU, Stock Actual, Stock Mínimo y Precio de Costo.
- Al definir el 'Stock Mínimo', el sistema le marcará con una etiqueta amarilla de advertencia cuando las existencias estén por agotarse.

2. ENTRADAS Y SALIDAS (KARDEX):
----------------------------------------
- Cada vez que compre repuestos a un proveedor, use el botón '+ Agregar Stock'.
- Cada vez que instale una pieza en el auto de un cliente, descuéntela asociándola a la Orden de Trabajo o Bitácora.
- El Kardex guarda fecha, hora, usuario y vehículo donde se instaló el repuesto, eliminando las pérdidas misteriosas de stock en el taller."
  },
  {
    title: 'Guía 04: Órdenes de Trabajo (OT) y Presupuestos PDF',
    category: 'Finanzas & Facturación',
    position: 4,
    icon: 'fa-file-invoice-dollar',
    content: "ÓRDENES DE TRABAJO, DESGLOSE Y COMPROBANTES PDF
======================================================
(Disponible en Plan Pro y Plan Full)

1. CREAR UNA ORDEN DE TRABAJO (OT):
----------------------------------------
- En 'Finanzas -> Órdenes de Trabajo', presione '+ Nueva OT'.
- Seleccione el Vehículo y Cliente.
- Desglose con transparencia:
  * Mano de Obra (Ej: 'Cambio pastillas delanteras y rectificado de discos').
  * Repuestos utilizados desde Bodega (con precio de venta sugerido).

2. GENERACIÓN DEL COMPROBANTE PDF PROFESIONAL:
----------------------------------------
- Al finalizar el trabajo o para entregar una cotización formal al cliente, presione 'Imprimir / Descargar PDF'.
- El PDF incluye el logo de su taller, el detalle valorizado, el kilometraje actual y las condiciones de garantía del trabajo realizado.
- Esto eleva la seriedad de su taller frente al cliente final."
  },
  {
    title: 'Guía 05: Cobros Online con Flow y Liquidaciones Quincenales',
    category: 'Pasarela Flow & Finanzas',
    position: 5,
    icon: 'fa-credit-card',
    content: "PAGOS CON TARJETA, CUOTAS Y LIQUIDACIONES FLOW
======================================================
(Disponible en Plan Full y Plan Gran Taller)

1. COBRO ONLINE DESDE EL CELULAR DEL CLIENTE:
----------------------------------------
- Envíe el enlace de pago seguro generado por T-MIM directamente por WhatsApp o correo al cliente.
- El cliente puede pagar desde su celular con Webpay Débito, Crédito o en cuotas según las condiciones de su banco.

2. MODALIDADES DE INTEGRACIÓN Y COSTOS:
----------------------------------------
- Opción 1: Si tiene su propia cuenta en Flow:
  Ingresa sus claves de API en el sistema. T-MIM cobra $0 de comisión sobre sus ventas y Flow le transfiere directamente.
- Opción 2: Si usa el Servicio de Recaudación T-MIM:
  T-MIM recauda las ventas por usted.
  Comisión total integrada: 4,89% + IVA (2,89% + IVA costo de pasarela Flow + 2,0% + IVA gestión administrativa y transferencias T-MIM).

3. CALENDARIO DE TRANSFERENCIAS (CADA 15 DÍAS):
----------------------------------------
- T-MIM transfiere el monto neto recaudado a su cuenta corriente los días 1 y 16 de cada mes.
- En 'Finanzas -> Liquidaciones' puede descargar la cartola quincenal para su contador con el desglose exacto de cada pago recibido."
  }
]

articles.each do |data|
  WikiArticle.create!(data.merge(is_global: true))
end

puts "Created #{WikiArticle.where(is_global: true).count} global wiki articles successfully!"
