# Estado del Proyecto - Sistema MIM (Mantenimiento Inteligente Maquinaria)
Fecha: Actualizado al 25 de Enero, 2026

## 1. Resumen Funcional Actual

El sistema se encuentra en una etapa avanzada de desarrollo con la mayoría de sus módulos core operativos y desplegados.

### Módulos Implementados y Operativos

1.  **Gestión de Usuarios:**
    *   Login seguro con roles (Administrador y Usuario).
    *   Vistas diferenciadas: Dashboard administrativo vs Perfil de usuario.

2.  **Activos y Maquinaria:**
    *   Inventario completo (Marca, Modelo, Patente).
    *   **Jerarquía Flexible:** Categorías -> Componentes -> Subcomponentes.
    *   Gestión de múltiples medidores (Horómetros, Odómetros) por activo.
    *   **Historial de Vida:** Reporte PDF completo de intervenciones.

3.  **Proveedores (Providers):**
    *   Gestión completa de proveedores (CRUD).
    *   Asignación de "Tags" (Habilidades/Especialidades) para filtrar proveedores por capacidades.

4.  **Bitácora (Logbook):**
    *   Registro de visitas técnicas y tareas.
    *   Captura de lecturas de medidores.
    *   Checklist dinámico basado en la estructura de componentes del activo.
    *   **Orden de Trabajo:** Generación de reportes PDF de las tareas realizadas (Soporte Español configurado y codificación UTF-8 corregida).

5.  **Planes de Mantenimiento:**
    *   **Biblioteca Centralizada:** Nuevo módulo con "Wizard" de creación paso a paso (Categoría -> Componente -> Regla).
    *   Asignación dinámica a componentes.
    *   **Proyección:** Reporte PDF de mantenimientos futuros basado en uso promedio diario.
    *   Dashboard de semáforos para control de vencimientos (Tiempo y Uso).

6.  **Motor de Alertas (Alert Engine):**
    *   Tarea programada diaria (`maintenance:daily_check`) que evalúa el estado de toda la flota.
    *   Envío automático de correos de resumen a administradores con ítems críticos y advertencias.

---

## 2. Estado Técnico

| Componente | Estado | Notas |
| :--- | :--- | :--- |
| **Rails Core** | Estable | Versión 8.2.0.alpha. Configuración sólida. |
| **Base de Datos** | Estable | PostgreSQL. Migraciones y Seeds robustos. |
| **Frontend** | Pulido | Bootstrap 5, Diseño "White Cards", Modals responsivos. Contrastes corregidos en modo oscuro. |
| **PDF** | Robusto | Grover configurado con fuentes locales (Docker), UTF-8 forzado y timeouts ajustados para estabilidad. |
| **Background Jobs** | Activo | Rake Tasks para mantenimiento diario. |

---

## 3. Hoja de Ruta (Roadmap)

### Corto Plazo (Próxima Sesión)
1.  **Arquitectura SaaS / Enterprise:** Discusión y planificación sobre la adaptación del sistema para modelo Software as a Service (Tenancy, Suscripciones, etc.) o despliegue Enterprise.
2.  **Pruebas (Testing):** Implementación de suite de pruebas automatizadas (Unitarias, Integración, E2E) para asegurar estabilidad antes de escalamiento.

### Futuro
*   **Refinamiento de UX:** Continuar puliendo detalles visuales.
*   **Expansión de Reportes:** Costos, Disponibilidad de Flota.
*   **Perezoso Express:** (Proyecto futuro mencionado por el usuario).

---

## 4. Bitácora de Cambios (Sesión Actual)

**Correcciones de Infraestructura (PDF):**
*   **Fuentes en Docker:** Se instalaron paquetes de fuentes (`fonts-liberation`, etc.) en el Dockerfile para solucionar el renderizado de símbolos en lugar de texto.
*   **Codificación UTF-8:** Se implementó `force_encoding("UTF-8")` y `<meta charset="UTF-8">` en los layouts de PDF para corregir problemas con tildes y caracteres especiales en Español.
*   **Estabilidad:** Se configuró Grover con `wait_until: 'domcontentloaded'` y timeout extendido (60s) para evitar caídas por lentitud en la carga de assets externos (CDN).

**Correcciones de Interfaz (UI):**
*   **Visibilidad en Modo Oscuro:** Se corrigieron los títulos y botones invisibles en las vistas de "Planes de Mantenimiento" y "Bitácora" ajustando las clases de color (`text-white`, `btn-outline-light`) para contrastar con el fondo azul oscuro corporativo.
*   **Layout PDF:** Se estandarizaron los templates de PDF (`.html.erb`) para asegurar compatibilidad total con el motor de renderizado.

---
*Este documento reemplaza versiones anteriores y debe ser considerado la fuente de verdad actual.*
