-- Este modelo limpia y prepara los datos para el análisis.

WITH source_data AS (
    -- Usamos 'source' para referenciar la tabla definida en sources.yml
    SELECT *
    FROM {{ source('bank_marketing_raw', 'raw_bank_marketing') }}
)

, cleaned_data AS (
    -- Usamos CTEs para la limpieza
    SELECT
        age,
        job,
        marital,
        education,

        -- Convertimos todas las variables con entradas tipo yes/no en True/False (Booleanas)
        -- Este es un cambio para probar CI
        (CASE 
            WHEN "default" = 'yes' THEN true 
            WHEN "default" = 'unknown' THEN null
            ELSE false 
        END) AS has_credit_in_default,
        
        (CASE 
            WHEN housing = 'yes' THEN true 
            WHEN housing = 'unknown' THEN null
            ELSE false 
        END) AS has_housing_loan,
        
        (CASE 
            WHEN loan = 'yes' THEN true 
            WHEN loan = 'unknown' THEN null
            ELSE false 
        END) AS has_personal_loan,
        
        contact AS contact_method,
        month AS contact_month,
        day_of_week AS contact_day_of_week,
        duration AS contact_duration_seconds,
        campaign AS campaign_contacts_count,
        pdays AS days_since_last_contact, -- 999 significa que no fue contactado según la documentación
        previous AS previous_contacts_count,
        poutcome AS previous_campaign_outcome,

        -- Columnas de KPIs
        emp_var_rate,
        cons_price_idx,
        cons_conf_idx,
        euribor3m,
        nr_employed,

        -- Variable que es el target
        y AS has_subscribed

    FROM source_data
    WHERE
        -- La documentación del dataset dice que duration=0 implica y="no"
        duration > 0
)

SELECT * FROM cleaned_data