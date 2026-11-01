# Plan Maestro T-MIM - Etapas de Implementación

> **Referencia:** Clon / Adaptación de la arquitectura probada de MIM para talleres mecánicos.

---

## 💎 Punto 1: Planes Comerciales y Lado Financiero (En UF)

### Estructura de Planes:
* **Plan Inicial / Express (0,5 UF / mes | ~$19.000 CLP):**
  * **Cupo:** Hasta 50 vehículos / mes.
  * **Público:** Talleres chicos o informales de motos y mecánica rápida.
  * **Módulos:** Registro de vehículos (por patente/chasis), ficha de clientes y bitácora de intervenciones básica.
  * **Restricción:** Sin bodega ni control de repuestos, sin finanzas avanzadas.
* **Plan Estándar (1,5 UF / mes | ~$57.000 CLP):**
  * **Cupo:** Hasta 50 vehículos / mes.
  * **Módulos:** Todo lo anterior + Bodega completa (Kardex, stock mínimo, alertas de reposición) + Bitácora avanzada.
* **Plan Pro (2,5 UF / mes | ~$95.000 CLP):**
  * **Cupo:** Hasta 150 vehículos / mes.
  * **Módulos:** Todo lo anterior + Finanzas completas, Órdenes de Trabajo (OT), desglose mano de obra vs repuestos y Comprobantes de Servicio PDF.
* **Plan Full (3,0 UF / mes | ~$114.000 CLP):**
  * **Cupo:** Hasta 300 vehículos / mes.
  * **Módulos:** Todo lo anterior + Pasarela de Pagos Flow integrada (pago online, cuotas) + Liquidaciones de caja.
* **Plan Gran Taller (A Medida / Consulta Interna):**
  * **Cupo:** +300 vehículos o personalizado según volumen real del taller.

### Landing Page y UI de Planes:
* Sección de planes en **formato acordeón interactivo**, ideal para celulares.
* Botón de contratación en cada acordeón que redirige al formulario de solicitud con el plan pre-seleccionado.
* **Incentivo por Pago Anual Adelantado:** 2 meses gratis + Cupo extra de vehículos (+20% a +25%).

---

## 🚦 Punto 2: Capacidad, Alertas al 95% y Bloqueo al 100%

* **Indicador en Dashboard Taller:**
  * Barra de progreso de flota/vehículos del mes (ej. `[ 28 / 50 Vehículos - 56% ]`).
* **Alerta al 95%:**
  * Banner de advertencia en Dashboard.
  * Disparo automático de correo al taller para anticipar la ampliación.
* **Bloqueo al 100%:**
  * Bloqueo visual en rojo y deshabilitación del botón "Nuevo Vehículo".
  * Botón directo: `🚀 Solicitar Más Cupo / Cambiar Plan`.
* **Herramientas en Dashboard SuperAdmin:**
  * Selector manual para cambiar de plan o asignar bolsas adicionales de cupo (+20, +50 vehículos) con 1 clic.

---

## 📝 Punto 3: Onboarding Legal y Bifurcación de Pagos (Clon MIM)

* **Flujo de Solicitud:** Formulario público -> Aprobación por SuperAdmin.
* **Invitación con Token Seguro de 48 Horas:** Clave temporal de 8 caracteres al correo del taller.
* **Aceptación Legal:** Contrato de Términos y Condiciones de Uso radicado en Puerto Montt, Chile (Ley 19.799 de Firma Electrónica).
* **Bifurcación de Pago:**
  * **Opción Flow:** Redirección a Webpay/Flow -> Autoactivación inmediata tras pago.
  * **Opción Transferencia:** Registro manual con datos bancarios de Mounkey SpA -> SuperAdmin concilia y activa.
* **Creación de Clave Definitiva:** Obligatoria post-activación/pago (alfanumérica con carácter especial).

---

## 📚 Punto 4: Módulo Wiki Práctico & Auditoría Final

* **Wiki Integrada en Sidebar (`/wiki`):**
  * Guías claras y numeradas paso a paso, redactadas en lenguaje de taller (sin capturas de pantalla pesadas para facilitar mantenimiento).
  * 5 guías base: Configuración inicial del taller, Clientes/Vehículos, Bodega/Kardex, Órdenes de Trabajo y Cobro/Entrega.
* **Auditoría Final:**
  * Escaneo estático con Brakeman (0 vulnerabilidades).
  * Pruebas de aislamiento multi-tenant (`acts_as_tenant`).
  * Preparación de Dockerfile de producción para despliegue en Hetzner CX22.
