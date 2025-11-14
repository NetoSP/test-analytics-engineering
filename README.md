---

## Sección 1: Preguntas de Opción Múltiple (30 puntos - 3 puntos cada una)
Selecciona la opción más adecuada para cada pregunta.

Nota. En mis ejemplos de contenido de archivos .yml usaré ; en vez de dos puntos ya que el preview muestra error.

**1. ¿Cuál es la función principal del archivo `dbt_project.yml`?**
    
    b) Configurar la estructura del proyecto dbt, incluyendo rutas de modelos, macros, seeds, variables y hooks.

    Ojo, notemos que en el archivo `dbt_project.yml` no se pueden declarar propiedades como las de las macros (para eso se utiliza el archivo `properties.yml`), sino que se enfoca en la configuración la estructura, como en qué directorios están ciertos recursos.

```yaml
    name; string

    config-version; 2
    version; version
    
    profile; profilename
    
    model-paths; [directorypath]
    seed-paths; [directorypath]
    test-paths; [directorypath]
    analysis-paths; [directorypath]
```
        

**2. En dbt, ¿qué significa el término "materialización" (materialization)?**

    a) El proceso de convertir el código SQL de dbt en objetos de base de datos como tablas o vistas.
    
    Existen distintos tipo de materialización como tabla, vista, incremental, ephemeral, materialized view. Una manera "sencilla" de verlo es como una forma más amigable de usar un INSERT INTO, aquí la matertialización guarda el output de una consulta en la estructura configurada, como una tabla.
    
**3. ¿Cuál de las siguientes materializaciones es la más adecuada para un modelo que contiene datos que cambian frecuentemente y necesitas acceder a la versión más actualizada?**
    
    b) `view` (para datos que cambian frecuentemente y quieres la versión en tiempo real sin costo de almacenamiento, asumiendo que la vista es performante sobre la base).
    La opción más viable es la vista, ya que esta más bien guarda "la consulta", entonces cada vez que se desea ver la vista, esta se comporta como si ejecutara de nuevo la consulta obteniendo de nuevo los datos más nuevos en ese preciso momento.

**4. ¿Qué problema busca resolver la materialización incremental?**

    a) Reducir el tiempo de ejecución de modelos con grandes volúmenes de datos, procesando solo los cambios desde la última ejecución.

    Aquí, a diferencia de la tabla que crea cada vez la tabla con todos los registros en su totalidad y no se va actualizando o la vista que vuelve a consultar para obtener datos más más actuales pero también toma todo el "histórico", lo que se busca es que cada vez que se utiliza la materialización inremental solo obtiene los registros más "nuevos" a partir de cierto tiempo, entonces nos ahorramos en volver a consultar registros antiguos. Esto es importante cuando el tipo de dato que se almacena tiene una cantidad enorme de registros donde sólo queremos ir actualizando los últimos.
    
**5. ¿Para qué se utilizan los packages en dbt?**

    a) Para encapsular y reutilizar la lógica de negocio, macros y modelos comunes, fomentando las mejores prácticas y la modularidad.

    Prácticamente empaquetamos código que reutilizaremos en el negocio/proyecto. Es similar a un paquete de python (algo que hago en mi actual empleo). Los paquetes los listamos en el archivo packages.yml. 

```yaml
packages;
  - package; paquete/modulo
    version; x.y.z
```

**6. ¿Cuál de los siguientes comandos se utiliza para ejecutar las pruebas definidas en un proyecto dbt?**

    c) `dbt test` (o `dbt build` que incluye tests, pero `dbt test` es específico para pruebas).

    Es muy similar a utilizar pytest en python y este muestra qué pruebas fallan. Un ejemplo de una prueba en mi schema.yml sería el siguiente

```yaml
    models;
  - name; pedidos
    columns;
      - name; pedido_id
        tests;
          - unique
          - not_null
```

**7. ¿Cuál es el propósito de los "seeds" en dbt?**

    a) Cargar datos estáticos o de referencia directamente en la base de datos a través de archivos CSV, ideal para datos pequeños y de configuración.

    Un ejemplo sería si necesitamos una tabla con el nombre de cada estado del pais y su abreviación, sabemos que los datos son una cantidad fija y que sus valor es casi imposible que cambie. Entonces, si tenemos otra tabla de ventas y queremos obtener la información del estado, usamos este seed como referencia al hacer el join, etc. 

    

**8. Si tienes una macro llamada `generate_uuid()` en tu proyecto, ¿cómo la llamarías dentro de un modelo SQL?**

    a) `{{ generate_uuid() }}`

    `{{...}}` es un delimitador de expresión y  `generate_uuid()` es una función, por lo tanto es la opción adecuada.

**9. ¿Cuál es la principal ventaja de usar la directiva `ref()` en lugar de referenciar directamente las tablas en SQL?**

    a) Permite a dbt construir un grafo de dependencias y gestionar el orden de ejecución, además de manejar automáticamente el esquema y las relaciones entre entornos.

    ref() tiene la ventaja de resolver automáticamente el esquema, entonces, por ejemplo, en producción y en dev podríamos tener distintos esquemas, entonces ref('mi_tabla') primero ejecuta el modelo para 'mi_tabla' y resuelve el esquema de este dependiendo de si estamos en producción o el dev.

**10. ¿Cuál de las siguientes afirmaciones sobre las "exposures" es verdadera?**

    b) Las exposures representan una capa de aplicación, dashboard (BI), o notebook que consume los datos transformados por dbt, documentando el uso downstream.

    Con "exposures" nos permiten documentar quién consume nuestros datos transformados por la dbt (a quien "exponemos" estos datos). Para ello solemos crear un archivo exposures.yml.

---

## Sección 2: Preguntas de Respuesta Corta y Ejemplos (40 puntos - 10 puntos cada una)
Proporciona respuestas concisas y, cuando se solicite, ejemplos de código.

**1. Explica la diferencia entre una materialización `view` y una materialización `table`. ¿Cuándo usarías una sobre la otra?**

Una vista solo una consulta SQL guardada. No almacena físicamente ningún dato. Esto ayuda a que se tienen datos en tiempo real; sin costo de almacenamiento, pero la contra de que puede ser lenta de consultar si la lógica es compleja.

Cuándo usarla: Ideal para modelos de staging (donde solo renombras columnas o haces casts de tipos) o para cualquier escenario donde los datos en tiempo real sean cruciales y la consulta sea rápida.

Una tabla es una copia física de los resultados de la consulta, almacenada en disco. Cuando ejecutas dbt run, dbt calcula la consulta SELECT una vez y guarda los resultados en una nueva tabla. La ventaja es que es muy rápida de consultar, ya que los datos están almacenados, la contra es requiere dbt run para actualizar y el costo de almacenamiento.

Usaría una vista cuando el la cantidad de registros no cambia seguido pero su valor sí, por ejemplo, si quiero analizar constantemente el valor en stock de varias empresas, sé que el valor varía muy constantemente, entonces una vista ayuda a mantener los datos actualizados.  En cambio, usaría una tabla para datos que no cambian su valor frecuentemente, por ejemplo una empresa pequeña que tiene los registros de sus empleados, sabemos que un empleado no cambiará de nombre, o si lo hace sería un caso extremádamente especial, y si es una empresa pequeña, no se esperaría modificaciones o nuevos rgistros muy frecuenmente. También utilizaría la tabla para modelos que usan muchas agregaciones que harían la vista muy tardada de consultar, pero sería un caso a analizar dependiendo la naturaleza de los datos.

**2. Describe cómo implementarías un modelo incremental en dbt. Incluye un ejemplo de cómo dbt gestiona las inserciones/actualizaciones con la cláusula `is_incremental()`.**

Primero, antes de implementarlo se necesita saber si el modelo incrementar es necesario, por ejemplo, si se desea agregar información de las transacciones bancarias realizadas por usuarios de un banco específico, se esperarían millones de transacciones por día, entonces sí aplicaría ese caso. Ahora, los pasos que haría serían los siguientes:

1. Configurar el modelo con materialized='incremental', para que sea incrementarl.

2. Usar {% if is_incremental() %} para definir el bloque donde filtraría con el WHERE el periodo de tiempo a agregar o modificar usualmente basado en una columna de timepo timestamp).

3. Si se necesita actualizar registros existentes (no solo añadir), defines un unique_key en la configuración.

Un ejemplo sería el siguiente:

```
{{
  config(
    materialized='incremental'
  )
}}

SELECT
  id AS evento_id,
  columna_1,
  columna_2,
  .
  .
  .
  columna_tiempo
FROM {{ ref('eventos') }}

{% if is_incremental() %}
  WHERE columna_tiempo > (SELECT MAX(columna_tiempo) FROM {{ this }})
{% endif %}
```

**3. ¿Qué son las "macros" en dbt y cómo pueden mejorar la mantenibilidad y reusabilidad del código en un proyecto dbt? Proporciona un ejemplo de una macro sencilla que podría ser útil en varios modelos.**

Respecto a la reusabilidad, si tienes una lógica repetitiva, por ejemplo, la naturaleza del negocio requiere que se obtenga el porcentaje de alñgun dato, se puede escribir una vez en una macro y llamarla en varios modelos diferentes.

Y relacionado al mantenimiento, si lógica del negocio requiere que esta cambie, es más fácil cambiar un sólo archivo que todos los que utilizan la lógica, podemos verlos como usar una función.

Un ejemplo es esta macro para convertir usd a mxn, supondremos que 1 usd = 20 mxn y que las tablas tienen todo en usd y necesitamos en mxn.

```
{% macro usd_a_mxn(columna) %}
    ({{ columna }} * 20)
{% endmacro %}
```

```
SELECT
  id,
  {{ usd_a_mxn('monto_en_usd') }} AS monto_en_mxn
FROM {{ ref('tabla') }}
```

**4. Imagina que tienes un modelo `stg_orders` y quieres asegurarte de que la columna `order_id` es única y no nula, y que la columna `order_date` siempre tiene una fecha válida (no es una fecha futura). ¿Cómo definirías estas pruebas en tu archivo `schema.yml`?**

Crearía un archivo models/staging/schema.yml con el siguiente contenido:

```yaml
models:
  - name: stg_orders
    columns:
      - name: order_id
        description: "La clave primaria"
        tests:
          - unique
          - not_null

      - name: order_date
        description: "Fecha de la orden."
        tests:
          - not_null # Primero validamos que no sea nulo
          - dbt_utils.expression_is_true: # requiere instalar el paquete
              expression: "order_date <= CURRENT_DATE"

``` 
---

## Sección 3: Jinja en dbt (20 puntos - 10 puntos cada una)
Demuestra tu comprensión de Jinja en dbt.

**1. Explica la diferencia entre los delimitadores `{{ ... }}` y `{% ... %}` en Jinja dentro de dbt. Proporciona un ejemplo donde usarías cada uno.**

`{{ ... }}` es un Delimitador de expresión. Se usa para imprimir o devolver un valor, se puede pensar en esto como un print() en Python. Sus usos comunas son llamar a ref(), source(), var() o macros que devuelven un valor como mi ejemplo del macho que convierte usd a mxn.

`{% ... %}` delimitador de control o lógico. Se utiliza para hacer comparaciones lógicas, como en un if, o para iterar como en un for.

Un ejemplo muy básico es cuando creamos un incremental. Analizemos el ejemplo anterior:

```
{{
  config(
    materialized='incremental'
  )
}}

SELECT
  id AS evento_id,
  columna_1,
  columna_2,
  .
  .
  .
  columna_tiempo
FROM {{ ref('eventos') }}

{% if is_incremental() %}
  WHERE columna_tiempo > (SELECT MAX(columna_tiempo) FROM {{ this }})
{% endif %}
```

Utilizamos `{{ ... }}` para poder utilizar la función de ref() y así referenciar una fuente de donde obtener los datos. Además, utilizamos `{% ... %}` para comparar si el modelo es incremental con el if, si lo es, entonces buscamos los datos más actuales y los agregamos.

**2. Tienes una tabla `stg_events` con una columna `event_type`. Quieres crear una tabla agregada `fct_event_summary` que cuente los eventos por tipo y por día, pero solo para un conjunto específico de `event_type` que podría variar. Usa una variable de proyecto y Jinja para lograr esto de forma dinámica.**

Definimos el archivo dbt_project.yml

```
name: 'mi_proyecto'
...

# Definimos variables globales para el proyecto
vars:
  eventos_deseados:
    - 'evento_1'
    - 'evento_2'
    - 'evento_3'
```

El ccódigo sql:

```
-- models/marts/fct_event_summary.sql

{{
  config(
    materialized='table'
  )
}}

{% set eventos_a_filtrar = var('eventos_deseados') %}

SELECT
    date,
    event_type,
    COUNT(*) AS event_count
FROM
    {{ ref('stg_events') }}
WHERE
    event_type IN (
        {% for event in eventos_a_filtrar %}
          '{{ event }}' 
          {% if not loop.last %},{% endif %} 
        {% endfor %}
    )
GROUP BY
    1, 2
```

---

## Sección 4: Pruebas Estadísticas Personalizadas con Macros (20 puntos - 10 puntos cada una)
Diseña y aplica pruebas estadísticas personalizadas usando macros.

**1. Describe el proceso general para crear una prueba personalizada en dbt usando una macro. ¿Qué estructura básica debe tener la macro de prueba y cómo se invocaría en `schema.yml`?**

1. Creamos el archivo .sql en tu carpeta macros, por ejemplo macros/mis_pruebas.sql.

2. La macro debe estar envuelta en los delimitadores {% test ... %} y {% endtest %}.

3. La macro debe aceptar al menos model y column_name como argumentos.

4. El SQL dentro de la macro debe ser una consulta SELECT que devuelva las filas que fallan.

Se invoca en schema.yml bajo la clave tests. Notemos que lo que importa es el nombre de la prueba y no del archivo tal cual.

Macro:
```
{% test test_mi_prueba_personalizada(model, column_name, otro_argumento) %}

    SELECT
        *
    FROM
        {{ model }}
    WHERE
        {{ column_name }} < {{ otro_argumento }}

{% endtest %}
```
schema.yml
```
models:
  - name: mi_modelo
    columns:
      - name: mi_columna
        tests:
          - mi_prueba_personalizada:
              otro_argumento: 100
```

**2. Crea una macro de prueba personalizada en dbt llamada `test_column_values_below_std_dev_threshold` que falle si algún valor en una columna numérica está más de N desviaciones estándar por encima del promedio. Los argumentos de la macro deben ser `model`, `column_name` y `std_dev_threshold` (el valor por defecto será 3).**

El archivo sería macros/anomaly_tests.sql

```
{% test test_column_values_below_std_dev_threshold(model, column_name, std_dev_threshold=3) %}

-- Esta prueba fallará si encuentra valores que superan el promedio + N*std

-- Calculamos los estadísticos de promedio y desviacsión estándar
WITH estadisticos AS (
    SELECT
        AVG({{ column_name }}) AS avg,
        STDDEV({{ column_name }}) AS std
    FROM
        {{ model }}
),

-- Definimos el rango permitido
limite AS (
    SELECT
        (avg + ({{ std_dev_threshold }} * std)) AS limite_sup
    FROM
        estadisticos
),

-- 3. Encontrar todas las filas que fallan la validación
validacion AS (
    SELECT
        m.* 
    FROM
        {{ model }} AS m
    CROSS JOIN 
        limite AS l
    WHERE
        m.{{ column_name }} > l.limite_sup
)

-- 4. Devolver las filas que fallan.
SELECT
    *
FROM
    validacion

{% endtest %}
```
---

## Sección 5: Diseño y Solución de Problemas Avanzados (30 puntos - 15 puntos cada una)
Aplica tus conocimientos de dbt para resolver los siguientes escenarios.

**Diseño de un Flujo de Datos con Fuentes Dispares y Modelos Exponibles:**

Tienes los siguientes datos crudos de diferentes fuentes:
*   Sistema de CRM (PostgreSQL): `customers` (`id_cliente`, `nombre`, `email`, `segmento`, `fecha_registro`)
*   Sistema de Ventas (Snowflake): `orders` (`id_pedido`, `id_cliente_crm`, `fecha_pedido`, `total_pedido`, `estado`, `id_vendedor`)
*   Sistema de Inventario (Google BigQuery): `products` (`id_producto`, `nombre_producto`, `categoria`, `precio_unitario`, `stock_actual`)
*   Tabla de Referencia (CSV seed): `currency_conversion_rates` (`fecha`, `moneda_origen`, `moneda_destino`, `tasa`)

Diseña un flujo de modelos dbt para crear una tabla final `fct_daily_sales_performance` que contenga las ventas diarias agregadas por vendedor y segmento de cliente, en una moneda común (USD).

La tabla final debe incluir:
*   `fecha_pedido`
*   `id_vendedor`
*   `nombre_vendedor` (asume que puedes obtener esto de un `stg_employees` que aún no existe, pero lo mencionarás)
*   `segmento_cliente`
*   `total_ventas_usd_dia`
*   `numero_pedidos_dia`

Además, define una exposure para un dashboard de BI llamado "Sales Performance Dashboard" que consumirá `fct_daily_sales_performance`.

Indica los nombres de los modelos (`stg_`, `int_`, `fct_`), sus materializaciones, las fuentes (`source`) y las relaciones generales entre ellos.

Divide tu respuesta en 5 puntos principales:
1.  **Fuentes**
2.  **Seeds**
3.  **Flujo de Modelos** (Nombres de modelos, materializaciones y un breve resumen de lo que hace cada uno)
4.  **Exposure**
5.  **Linaje** (descripción del grafo de dependencias o un diagrama textual simple)

Empecemos:

1. Fuentes. Empezamos creando los archivos YAML en models/staging/ para declarar las tablas:
models/staging/crm/crm_sources.yml
```
sources:
  - name: postgres_crm
    description: "Base de datos del CRM en PostgreSQL."
    database: database_name
    schema: crm_schema
    tables:
      - name: customers
```

models/staging/sales/orders_sources.yml
```
sources:
  - name: snowflake_orders
    description: "Base de datos de Snowflake de ordenes."
    database: database_name
    schema: orders_schema
    tables:
      - name: orders
```

models/staging/rrhh/rrhh_sources.yml Estes es para el stg_employees que no existe
```
sources:
  - name: rrhh_system
    description: "Fuente de datos de RRHH para info de empleados."
    database: database_name
    schema: rrhh_schema
    tables:
      - name: employees
        identifier: "employees_raw"
        columns:
          - name: id_vendedor
          - name: nombre
```

2. Para los seed, utilizaremos uno para la conversión de las monedas a usd, para esto, supondremos que la equivalencia siempre es la misma, es decir, que por ejemplo 1 usd siempre son 20 mxn, solo para simplifiar este diagrama. Si no, deberíaos considerar el valor el día de la consulta, esto implicaría también una vista posiblemente (ya que es un dato altamente variable).

seeds/currency_conversion_rates.csv

```
moneda_origen,tasa_usd
MXN,0.05
EUR,1.08
CAD,0.75
```

3. Flujo
    
    1. stg_crm__customers.sql
    
    Materialización: view
    
    Lógica: `SELECT id_cliente AS customer_id, segmento AS customer_segment, ... FROM {{ source('postgres_crm', 'customers') }}`
    
    2. stg_sales__orders.sql
    
    Materialización: view
    
    Lógica: `SELECT id_pedido AS order_id, id_cliente_crm AS customer_id, fecha_pedido AS order_date, total_pedido AS order_total_local, moneda AS order_currency, ... FROM {{ source('snowflake_orders', 'orders') }}`
    
    3. stg_employees.sql (Del source hipotético)
    
    Materialización: view
    
    Lógica: `SELECT id_vendedor AS employee_id, nombre AS nombre_vendedor FROM {{ source('rrhh_system', 'employees') }}`
    
    4. stg_seed__currency_rates.sql
    
    Materialización: table (no cambia, entonces puede quedarse como tabla).
    
    Lógica: `SELECT moneda_origen, tasa_usd FROM {{ ref('currency_conversion_rates') }}`

Ahora nos encargamos de crear las tablas o modelos necesarios. 

Obtenemos la información de los custumer y orders en la siguiente materialización ephemeral int_orders_with_customer_segment.sql:

```
SELECT
  orders.*
  custumers.customer_segment
FROM {{ ref('stg_sales__orders') }} AS orders
LEFT JOIN {{ ref('stg_crm__customers') }} AS custumers
  ON orders.customer_id = custumers.customer_id
```

Finalmente obtenemos nuestra tabla (materializaciónt tabla) final fct_daily_sales_performance.sql:

```
WITH orders_with_segment AS (
    {{ ref('int_orders_with_customer_segment') }}
),

orders_in_usd AS (
    -- Convertir a USD 
    SELECT
        orders.*,
        orders.order_total_local * usd.tasa_usd AS order_total_usd
    FROM orders_with_segment AS orders
    LEFT JOIN {{ ref('stg_seed__currency_rates') }} AS usd
        ON orders.order_currency = usd.moneda_origen
    WHERE
        orders.order_status = 'completed' 
)

-- Agregación final 
SELECT
    DATE(orders.order_date) AS fecha_pedido,
    orders.employee_id AS id_vendedor,
    employees.nombre_vendedor,
    orders.customer_segment AS segmento_cliente,
    SUM(orders.order_total_usd) AS total_ventas_usd_dia,
    COUNT(DISTINCT orders.order_id) AS numero_pedidos_dia
FROM orders_in_usd AS orders
LEFT JOIN {{ ref('stg_employees') }} AS employees
    ON orders.employee_id = employees.employee_id
GROUP BY
    1, 2, 3, 4
```
    
4. Para el exposure tenemos el siguiente archivo como ejemplo:
```
exposures:
  - name: Sales Performance Dashboard
    type: dashboard
    maturity: high
    description: "Dashboard para monitorear el rendimiento de ventas diario por vendedor y segmento."
    
    url: url
    
    owner:
      name: 'Equipo de Ventas'
      email: 'mail@mail.com

    depends_on:
      - ref('fct_daily_sales_performance')
```
5. El siguiente diagrama muestra el flujo:

```
└── [EXPOSURE] Sales Performance Dashboard
    └── 
        └── [MART] fct_daily_sales_performance
            ├── 
            │   └── [INT] int_orders_with_customer_segment
            │       ├── 
            │       │   └── [STG] stg_sales__orders
            │       │       └── 
            │       │           └── [SOURCE] snowflake_orders (tabla: orders)
            │       │
            │       └── [STG] stg_crm__customers
            │           └── 
            │               └── [SOURCE] postgres_crm (tabla: customers)
            │
            ├── 
            │   └── [STG] stg_employees
            │       └── 
            │           └── [SOURCE] rrhh_system (tabla: employees)
            │
            └── [STG] stg_seed__currency_rates
                └── 
                    └── [SEED] currency_conversion_rates (archivo: csv)
```


    

---

**¡Buena suerte con el examen teorico!**

---

# Ejercicio Práctico para Analytics Engineering

Debe realizar un fork de este repositorio para desarrollar y entregar su trabajo.

Si está interesado en aplicar al test, puede enviar un correo a jgarcial@deacero.com.

## Ejercicio DBT

Este ejercicio utiliza datos de una campaña de marketing por correo electrónico disponibles en el [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/222/bank+marketing). Los datos contienen información sobre diversas campañas de marketing directo de una institución bancaria.

**Objetivo del Ejercicio:**

El objetivo es evaluar el dominio de la herramienta DBT (Data Build Tool) del candidato, su capacidad para incorporar pruebas unitarias, mantener la calidad de los datos y desplegar modelos de datos en BigQuery. El objetivo de negocio es crear un Data Mart que permita al equipo de marketing analizar la efectividad de sus campañas, enfocándose en KPIs como la tasa de conversión, el número de contactos exitosos y la segmentación de clientes.

### Instrucciones del Ejercicio:

1. **Configuración del Proyecto DBT:**
    - Crea un nuevo proyecto de DBT.
    - Conéctalo a BigQuery. Asegúrate de configurar correctamente las credenciales y el dataset de destino.
    
2. **Obtención de Datos:**
    - Descarga los datos del [Bank Marketing dataset](https://archive.ics.uci.edu/dataset/222/bank+marketing).
    - Carga los datos en una tabla en BigQuery llamada `raw_bank_marketing`.

3. **Modelado:**
    - Crea un modelo `staging_bank_marketing.sql` para transformar los datos iniciales utilizando CTEs (Common Table Expressions). Este modelo debe realizar las siguientes tareas:
        - Limpiar y normalizar los datos.
        - Filtrar registros irrelevantes.
        - Crear nuevas columnas necesarias para el análisis.
        
    - Crea un modelo `kpi_bank_marketing.sql` para agregar los KPIs de marketing utilizando CTEs. Este modelo debe calcular:
        - Tasa de conversión: porcentaje de contactos exitosos sobre el total de contactos.
        - Número de contactos exitosos: total de conversiones logradas.
        - Segmentación de clientes: clasificación de clientes basada en criterios relevantes como edad, ocupación, etc.
       
4. **Pruebas Unitarias:**
    - Agrega pruebas unitarias en el archivo `schema.yml` para asegurar la integridad de los datos. Incluye pruebas para:
        - Validar tipos de datos.
        - Comprobar valores nulos.
        - Verificar rangos y unicidad de campos clave.
    
5. **Despliegue y Calidad:**
    - Configura un pipeline CI/CD para desplegar los modelos DBT usando herramientas como GitHub Actions o GitLab CI. Asegúrate de incluir pasos para:
        - Validación de código.
        - Ejecución de pruebas unitarias.
        - Despliegue en BigQuery.
    - Configura alertas para pruebas fallidas y realiza auditorías periódicas de calidad de datos. Considera el uso de herramientas como dbt tests, Great Expectations, o similares para automatizar estas auditorías.

### Entrega del Ejercicio

- Suba su proyecto a un repositorio de GitHub.
- Asegúrese de que el repositorio incluya:
    - Todo el código fuente del proyecto DBT.
    - Documentación que explique el proceso seguido, las decisiones tomadas y cómo ejecutar el proyecto.
    - Instrucciones claras sobre cómo configurar y ejecutar el pipeline CI/CD.

### Criterios de Evaluación

- **Exactitud y eficacia del modelo:** ¿Los modelos transforman y agregan los datos de manera correcta y eficiente?
- **Calidad del código:** ¿El código es claro, bien documentado y sigue buenas prácticas?
- **Implementación de pruebas unitarias:** ¿Las pruebas unitarias son exhaustivas y cubren los casos relevantes?
- **Despliegue y automatización:** ¿El pipeline CI/CD está correctamente configurado y automatiza el proceso de despliegue y pruebas?

¡Suerte a todos! 

---
