{{ config(materialized='table') }}

WITH weather AS (
  SELECT DISTINCT
    condition,
    description
  FROM {{ ref('stg_weather') }}
),

forecast AS (
  SELECT DISTINCT
    condition,
    description
  FROM {{ ref('stg_forecast') }}
),

all_conditions AS (
  SELECT DISTINCT *
  FROM weather
  UNION DISTINCT
  SELECT DISTINCT *
  FROM forecast
)

SELECT
  condition,
  description,
  CASE description
    WHEN 'broken clouds' THEN 'nuages fragmentés'
    WHEN 'clear sky' THEN 'ciel dégagé'
    WHEN 'few clouds' THEN 'peu nuageux'
    WHEN 'light intensity shower rain' THEN 'averses légères'
    WHEN 'légère pluie' THEN 'légère pluie'
    WHEN 'mist' THEN 'brume'
    WHEN 'overcast clouds' THEN 'couvert'
    WHEN 'scattered clouds' THEN 'nuages épars'
    ELSE description
  END AS description_fr

FROM all_conditions