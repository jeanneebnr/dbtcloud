{{ config(materialized='table') }}

WITH horaires AS (
    SELECT date, annee, mois, jour, jour_semaine FROM {{ ref('stg_horaires_2023') }}
    UNION ALL
    SELECT date, annee, mois, jour, jour_semaine FROM {{ ref('stg_horaires_2024') }}
),

jours_feries AS (
    SELECT date FROM {{ ref('jours_feries_2023') }}
    UNION ALL
    SELECT date FROM {{ ref('jours_feries_2024') }}
),

vacances AS (
    SELECT date_debut, date_fin FROM {{ ref('vacances_scolaires_zone_c_2023') }}
    UNION ALL
    SELECT date_debut, date_fin FROM {{ ref('vacances_scolaires_zone_c_2024') }}
)

SELECT DISTINCT
    date,
    annee,
    mois,
    jour,
    jour_semaine,
    CASE
        WHEN EXTRACT(DAYOFWEEK FROM date) = 1
             THEN 'DIJFP'
        WHEN date IN (SELECT CAST(date AS DATE) FROM jours_feries)
             THEN 'DIJFP'
        WHEN EXTRACT(DAYOFWEEK FROM date) = 7
             AND EXISTS (SELECT 1 FROM vacances v WHERE date BETWEEN v.date_debut AND v.date_fin)
             THEN 'SAVS'
        WHEN EXTRACT(DAYOFWEEK FROM date) = 7
             THEN 'SAHV'
        WHEN EXISTS (SELECT 1 FROM vacances v WHERE date BETWEEN v.date_debut AND v.date_fin)
             THEN 'JOVS'
        ELSE 'JOHV'
    END AS categorie_jour

FROM horaires
order by date asc