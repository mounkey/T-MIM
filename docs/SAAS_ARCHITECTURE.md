# Arquitectura Híbrida SaaS / Enterprise

Este documento describe la estrategia de arquitectura para "MIM" (Maintenance Intelligence Module), permitiendo que el **mismo código base** soporte dos modelos de despliegue diferentes: SaaS Multi-inquilino y Enterprise Single-Tenant.

## 1. Concepto Central: "Multitenancy" Nativo
La aplicación está diseñada bajo el principio de que **todos los datos pertenecen a una Cuenta (Account)**. Aunque se instale para un solo cliente, el código internamente sigue validando la propiedad de los datos.

### Beneficios
*   **Un solo Repositorio:** No hay ramas separadas para "Enterprise" o "SaaS". Las correcciones de bugs aplican a todos.
*   **Seguridad por Diseño:** Es imposible que un usuario vea datos que no le pertenecen, porque el filtro de seguridad está en el núcleo de la base de datos (Row-Level Security o Scopes Globales).

---

## 2. Estrategia de Base de Datos

### Nueva Entidad: `Account`
Se debe introducir una tabla maestra `accounts`.
*   `name`: Nombre de la empresa (ej: "Minera Escondida").
*   `subdomain` (Opcional): Para identificar al cliente por URL (ej: `minera.mim-app.com`).

### Modificación de Tablas Existentes
Todas las tablas principales deben agregar una columna `account_id` (Foreign Key):
*   `assets` -> `account_id`
*   `users` -> `account_id`
*   `providers` -> `account_id`
*   `asset_categories` -> `account_id` (Permite categorías personalizadas por cliente).

---

## 3. Modelos de Despliegue

### A. Modelo SaaS (Multi-Tenant)
**Infraestructura:** Un servidor grande compartido (ej: AWS, Render, Heroku).
**Base de Datos:** Una sola base de datos PostgreSQL compartida.

**Flujo:**
1.  El usuario entra a `cliente-a.mim.com`.
2.  El sistema detecta el subdominio `cliente-a`.
3.  Carga la cuenta asociada.
4.  Establece el `Current.account`.
5.  Todas las consultas SQL añaden automáticamente `WHERE account_id = X`.

### B. Modelo Enterprise (Single-Tenant)
**Infraestructura:** Servidor privado dentro de la VPN del cliente o una instancia aislada en la nube.
**Base de Datos:** Base de datos PostgreSQL exclusiva para ese cliente.

**Flujo:**
1.  El código es **exactamente el mismo**.
2.  En la tabla `accounts` de esta base de datos, solo existe **1 registro**.
3.  Se configura una variable de entorno: `SINGLE_TENANT_MODE=true`.
4.  El sistema omite la búsqueda por subdominio y carga automáticamente la única cuenta existente.

---

## 4. Hoja de Ruta de Implementación (Técnica)

1.  **Migraciones:**
    *   Crear tabla `accounts`.
    *   Agregar `account_id` a todas las tablas de negocio.
    *   Migrar datos existentes a una "Cuenta Default".

2.  **Segregación Lógica (Scope):**
    *   Implementar `acts_as_tenant` (Gema recomendada) o `CurrentAttributes` nativo de Rails.
    *   Ejemplo en modelo:
        ```ruby
        class Asset < ApplicationRecord
          acts_as_tenant :account
        end
        ```

3.  **Adaptación de Controladores:**
    *   `ApplicationController` debe tener un `before_action :set_tenant`.

---

## 5. Resumen Ejecutivo
Esta arquitectura permite vender el software como servicio mensual (SaaS) a clientes pequeños y vender licencias instaladas (Enterprise) a clientes grandes, sin duplicar el esfuerzo de desarrollo.
