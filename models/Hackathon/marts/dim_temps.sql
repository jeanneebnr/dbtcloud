{{ config(materialized='table') }}

WITH timestamps AS (
  SELECT DISTINCT PARSE_DATETIME('%Y-%m-%d %H:%M:%S', timestamp_mesure) AS ts
  FROM {{ ref('stg_weather') }}
  UNION DISTINCT
  SELECT DISTINCT PARSE_DATETIME('%Y-%m-%d %H:%M:%S', timestamp_prevision) AS ts
  FROM {{ ref('stg_forecast') }}
)

SELECT
  ROW_NUMBER() OVER (ORDER BY ts) AS temps_id,
  FORMAT_DATETIME('%Y-%m-%d %H:%M:%S', ts) AS timestamp,
  DATE(ts) AS date,
  TIME(ts) AS heure,
  EXTRACT(YEAR FROM ts) AS annee,
  EXTRACT(MONTH FROM ts) AS mois,
  EXTRACT(DAY FROM ts) AS jour,
  EXTRACT(HOUR FROM ts) AS heure_chiffre,
  EXTRACT(MINUTE FROM ts) AS minute,
  EXTRACT(DAYOFWEEK FROM ts) AS jour_semaine,
  CASE EXTRACT(DAYOFWEEK FROM ts)
    WHEN 1 THEN 'Dimanche'
    WHEN 2 THEN 'Lundi'
    WHEN 3 THEN 'Mardi'
    WHEN 4 THEN 'Mercredi'
    WHEN 5 THEN 'Jeudi'
    WHEN 6 THEN 'Vendredi'
    WHEN 7 THEN 'Samedi'
  END AS nom_jour
FROM timestamps
ORDER BY ts