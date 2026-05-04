WITH transform AS (
  SELECT
    JSON_VALUE(raw_data, '$.city.name') AS ville,
    JSON_VALUE(raw_data, '$.city.country') AS pays,

    CAST(JSON_VALUE(raw_data, '$.city.coord.lon') AS FLOAT64) AS longitude,
    CAST(JSON_VALUE(raw_data, '$.city.coord.lat') AS FLOAT64) AS latitude,

    CAST(JSON_VALUE(item, '$.main.temp') AS FLOAT64) AS temperature,
    CAST(JSON_VALUE(item, '$.main.temp_min') AS FLOAT64) AS temp_min,
    CAST(JSON_VALUE(item, '$.main.temp_max') AS FLOAT64) AS temp_max,

    CAST(JSON_VALUE(item, '$.main.feels_like') AS FLOAT64) AS feels_like,
    CAST(JSON_VALUE(item, '$.main.humidity') AS INT64) AS humidite,
    CAST(JSON_VALUE(item, '$.main.pressure') AS INT64) AS pression,

    CAST(JSON_VALUE(item, '$.visibility') AS INT64) AS visibilite,
    JSON_VALUE(item, '$.weather[0].main') AS condition,

    CAST(JSON_VALUE(item, '$.wind.speed') AS FLOAT64) AS vent_vitesse,
    CAST(JSON_VALUE(item, '$.wind.deg') AS INT64) AS vent_direction,
    CAST(JSON_VALUE(item, '$.wind.gust') AS FLOAT64) AS vent_rafale,

    CAST(JSON_VALUE(item, '$.clouds.all') AS INT64) AS nuages,
    CAST(JSON_VALUE(item, '$.pop') AS FLOAT64) AS probabilite_pluie,

    TIMESTAMP_SECONDS(CAST(JSON_VALUE(item, '$.dt') AS INT64)) AS timestamp_prevision

  FROM {{ source('hackathon_openweather', 'raw_forecast') }},
  UNNEST(JSON_QUERY_ARRAY(raw_data, '$.list')) AS item
  WHERE raw_data IS NOT NULL
)

, enriched AS (
  SELECT *,(
    CASE
        WHEN temperature BETWEEN 15 AND 25 THEN 25
        WHEN temperature BETWEEN 10 AND 30 THEN 18
        ELSE 10
    END
      +
    CASE
        WHEN condition = 'Rain' THEN 0
        WHEN probabilite_pluie > 0.6 THEN 5
        WHEN probabilite_pluie > 0.3 THEN 10
        ELSE 20
      END
      +
      CASE
        WHEN vent_vitesse > 10 THEN 5
        WHEN vent_vitesse > 5 THEN 10
        ELSE 20
      END
      +
      CASE
        WHEN visibilite < 2000 THEN 5
        WHEN visibilite < 5000 THEN 10
        ELSE 20
      END
      +
      CASE
        WHEN nuages > 80 THEN 10
        WHEN nuages > 50 THEN 15
        ELSE 20
      END
    ) AS indice_mobilite

  FROM transform
)

, clean AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY ville,
      DATE(timestamp_prevision),
      EXTRACT(HOUR FROM timestamp_prevision)
      ORDER BY timestamp_prevision DESC
    ) AS rn
  FROM enriched
  WHERE ville IS NOT NULL
    AND temperature IS NOT NULL
    AND timestamp_prevision IS NOT NULL
)

SELECT * EXCEPT(rn)
FROM clean
WHERE rn = 1