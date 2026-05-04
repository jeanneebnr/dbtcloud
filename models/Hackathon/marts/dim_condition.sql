{{ config(materialized='table') }}

WITH all_conditions AS (
  SELECT DISTINCT condition, description
  FROM {{ ref('stg_weather') }}
  UNION DISTINCT
  SELECT DISTINCT condition, description
  FROM {{ ref('stg_forecast') }}
)

SELECT
  ROW_NUMBER() OVER (ORDER BY condition) AS condition_id,
  condition,
  description,
  CASE description
    WHEN 'broken clouds' THEN 'nuages fragmentés'
    WHEN 'ciel dégagé' THEN 'ciel dégagé'
    WHEN 'clear sky' THEN 'ciel dégagé'
    WHEN 'couvert' THEN 'couvert'
    WHEN 'few clouds' THEN 'peu nuageux'
    WHEN 'light intensity shower rain' THEN 'averses légères'
    WHEN 'légère pluie' THEN 'légère pluie'
    WHEN 'mist' THEN 'brume'
    WHEN 'nuageux' THEN 'nuageux'
    WHEN 'overcast clouds' THEN 'couvert'
    WHEN 'partiellement nuageux' THEN 'partiellement nuageux'
    WHEN 'peu nuageux' THEN 'peu nuageux'
    WHEN 'pluie modérée' THEN 'pluie modérée'
    WHEN 'scattered clouds' THEN 'nuages épars'
    ELSE description
  END AS description_fr
FROM all_conditions