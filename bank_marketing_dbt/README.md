# Proyecto dbt: Bank Marketing Analytics

Este proyecto es una solución al Ejercicio Práctico para Analytics Engineering. Se implementa un pipeline de dbt para analizar el dataset "Bank Marketing" de UCI.

## Objetivo de Negocio

Crear un Data Mart que permita al equipo de marketing analizar la efectividad de sus campañas, enfocándose en KPIs como la tasa de conversión, el número de contactos exitosos y la segmentación de clientes.

## Arquitectura del Proyecto

- **Fuente:** Google BigQuery (Dataset: `bank_marketing_raw`)
- **Transformación:** dbt (Data Build Tool)
- **Capa 1: Staging (`staging_bank_marketing`)**: Vistas que limpian, normalizan y estandarizan los datos crudos.
- **Capa 2: Mart (`kpi_bank_marketing`)**: Tablas agregadas que calculan KPIs por segmento de cliente.
- **CI/CD:** GitHub Actions para validación y pruebas automáticas en Pull Requests.

## Cómo Ejecutar el Proyecto

### 1. Prerrequisitos

- Python 3.9+
- Una cuenta de Google Cloud con un proyecto BigQuery.
- Una clave de cuenta de servicio de GCP con roles "BigQuery Data Editor" y "BigQuery Job User" (se eligieron estos roles y no directamente el de admin ya que un rol de admin tiene todos los permisos y esa es una práctica no segura).

### 2. Configuración Inicial

1.  **Clonar Repositorio:**
    `git clone https://github.com/NetoSP/test-analytics-engineering.git`
    `cd bank_marketing_dbt`

2.  **Cargar Datos Crudos:**
    Cargar los datos de `bank-additional-full.csv` (con delimitador `;`) a BigQuery en el dataset `bank_marketing_raw`.

3.  **Configurar Perfil:**
    Crea un archivo `~/.dbt/profiles.yml` (fuera de este repositorio).
    
    ```yaml
    bank_marketing_dbt:
      target: dev
      outputs:
        dev:
          type: bigquery
          method: service-account
          project: "tu-gcp-project-id"
          dataset: "dbt_dev" # Dataset para tu desarrollo
          threads: 4
          keyfile: "/path/a/tu/gcp-sa-key.json"
    ```

### 3. Ejecución

1.  **Instalar Dependencias:**
    `pip install dbt-bigquery`
    `dbt deps` 

2.  **Correr y Probar (Desarrollo):**
    `dbt build`

3.  **Explorar Documentación (Opcional pero recomendado):**
    `dbt docs generate`
    `dbt docs serve`