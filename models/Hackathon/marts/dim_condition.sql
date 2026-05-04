{{ config(materialized='table') }}

WITH all_conditions AS (
  SELECT DISTINCT condition, description
  FROM {{ ref('stg_weather') }}

  UNION DISTINCT

  SELECT DISTINCT condition, CAST(NULL AS STRING) AS description
  FROM {{ ref('stg_forecast') }}
)

SELECT
  ROW_NUMBER() OVER (ORDER BY condition) AS condition_id,
  condition,
  description,
  CASE
    WHEN description = 'broken clouds' THEN 'nuages fragmentés'
    WHEN description = 'ciel dégagé' THEN 'ciel dégagé'
    WHEN description = 'clear sky' THEN 'ciel dégagé'
    WHEN description = 'couvert' THEN 'couvert'
    WHEN description = 'few clouds' THEN 'peu nuageux'
    WHEN description = 'light intensity shower rain' THEN 'averses légères'
    WHEN description = 'légère pluie' THEN 'légère pluie'
    WHEN description = 'mist' THEN 'brume'
    WHEN description = 'nuageux' THEN 'nuageux'
    WHEN description = 'overcast clouds' THEN 'couvert'
    WHEN description = 'partiellement nuageux' THEN 'partiellement nuageux'
    WHEN description = 'peu nuageux' THEN 'peu nuageux'
    WHEN description = 'pluie modérée' THEN 'pluie modérée'
    WHEN description = 'scattered clouds' THEN 'nuages épars'
    ELSE description
  END AS description_fr
FROM all_conditions