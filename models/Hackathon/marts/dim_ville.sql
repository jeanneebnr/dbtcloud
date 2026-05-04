{{ config(materialized='table') }}

WITH weather AS (
  SELECT DISTINCT ville, pays, longitude, latitude
  FROM {{ ref('stg_weather') }}
),

forecast AS (
  SELECT DISTINCT ville, pays, longitude, latitude
  FROM {{ ref('stg_forecast') }}
),

all_villes AS (
  SELECT DISTINCT *
  FROM weather
  UNION DISTINCT
  SELECT DISTINCT *
  FROM forecast
)

SELECT
  ROW_NUMBER() OVER (ORDER BY ville) AS ville_id,
  ville,
  pays,
  longitude,
  latitude
FROM all_villes