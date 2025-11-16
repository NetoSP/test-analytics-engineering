-- Este modelo crea el Data Mart final para el análisis de Marketing.

WITH stg_data AS (
    SELECT * FROM {{ ref('staging_bank_marketing') }}
)

, segmentation AS (
    SELECT
        *,
        -- Segmentación por edad
        CASE
            WHEN age BETWEEN 18 AND 29 THEN '18-29 (Joven)'
            WHEN age BETWEEN 30 AND 39 THEN '30-39 (Adulto joven)'
            WHEN age BETWEEN 40 AND 49 THEN '40-49 (Adulto)'
            WHEN age BETWEEN 50 AND 59 THEN '50-59 (Adulto mayor)'
            ELSE '60- (Posible retirado)'
        END AS age_group
        
    FROM stg_data
)

, aggregated_kpis AS (
    SELECT
        --Columas utilizadas para agrupar
        age_group,
        job,
        marital,
        education,
        
        -- Cálculo de KPIs
        COUNT(*) AS total_contacts,
        SUM(CASE WHEN has_subscribed THEN 1 ELSE 0 END) AS successful_contacts,
        AVG(CASE WHEN has_subscribed THEN 1 ELSE 0 END) AS conversion_rate

    FROM segmentation
    GROUP BY
        1, 2, 3, 4
)

SELECT * FROM aggregated_kpis
ORDER BY
    successful_contacts DESC,
    conversion_rate DESC