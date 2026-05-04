{{ config(materialized='table') }}

WITH weather AS (
  SELECT DISTINCT
    ville,
    pays,
    longitude,
    latitude
  FROM {{ ref('stg_weather') }}
),

forecast AS (
  SELECT DISTINCT
    ville,
    pays,
    longitude,
    latitude
  FROM {{ ref('stg_forecast') }}
)

SELECT DISTINCT *
FROM weather

UNION DISTINCT

SELECT DISTINCT *
FROM forecast