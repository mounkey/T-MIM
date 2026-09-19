# Estado del Proyecto - T-MIM (Talleres y Mantención Inteligente)
Fecha: Actualizado al 18 de Septiembre, 2026

## 1. Resumen de Fases y Progreso

```
[ Fase 0: Setup & Fork ✅ ] ➔ [ Fase 1: Clientes & Vehículos ✅ ] ➔ [ Fase 2: Bodega & Kardex ✅ ] ➔ [ Fase 3: Finanzas, Abonos & Liquidaciones Flow ✅ ] ➔ [ Fase 4: Reportes & QA ⏳ ]
```

---

## 2. Módulos Implementados

### ✅ Fase 0: Aislamiento e Infraestructura
* Base de datos independiente `tmim_development` en puerto `5433` (Web en `3001`).
* Logo corporativo oficial integrado.

### ✅ Fase 1: Clientes y Vehículos
* Modelo `Client` multitenant y relación con `Asset`.
* Vistas adaptadas con diseño automotriz.

### ✅ Fase 2: Bodega, Kardex y Reservas
* Modelos `WarehouseItem` y `StockMovement`.
* Stock Físico, Reservado y Disponible.
* Kardex y consumo directo de repuestos en la Bitácora/OT.

### ✅ Fase 3: Finanzas, Recaudación, Abonos y Liquidaciones Quincenales
1. **Lado Taller / Empresa (`/finanzas`):**
   * **Control en Dos Ejes:** Estado Mecánico (*Diagnóstico, Reparación, Finalizado, Entregado*) vs Estado Financiero (*Sin Pago, Abonado, Pagado Total*).
   * **Dashboard de Finanzas:** 3 Tarjetas KPIs (Ventas del Mes, Comisiones Retenidas Flow, Neto por Recibir).
   * **Grid de Órdenes:** Folio único (`OT-0001`), saldos en tiempo real y modal interactivo de repuestos (clic/doble clic).
   * **Abonos Rápidos:** Registro de pagos presenciales (Caja, POS, Transferencia) y Flow Online.
   * **Comprobante PDF:** Generación de comprobante con los datos del taller (nombre, dirección, fono y email) y pie de página sutil provisto por T-MIM.
2. **Lado Superadmin / Matriz Recaudadora (`/superadmin/liquidaciones`):**
   * **Billetera Central Flow:** Monitoreo global de recaudación online de toda la red de talleres.
   * **Comisiones Ganadas T-MIM:** Cálculo de ganancias por fee de plataforma.
   * **Generador de Cortes Quincenales:** Agrupa automáticamente los pagos Flow no liquidados por taller y rango de fechas.
   * **Nómina de Transferencias:** Registro del código de transferencia bancaria y paso a estado `Transferido`.
   * **Dashboard Superadmin:** Métricas en tiempo real de empresas, recaudación y saldo pendiente de liquidar.

---

## 3. Próximos Pasos (Fase 4: Reportes, QA y Demo Comercial)
* [ ] Informe de Stock y Bodega en PDF (Kardex, valoración de inventario, stock bajo).
* [ ] Mantenedores de Categorías de Repuestos y Unidades de Medida en Configuración.
* [ ] Hoja de Vida del Auto en PDF como comprobante de entrega.
* [ ] Seeds demo para presentaciones comerciales.
