WITH base AS (
  SELECT

    JSON_VALUE(raw_data, '$.city.name') AS ville,
    JSON_VALUE(raw_data, '$.city.country') AS pays,
    CAST(JSON_VALUE(raw_data, '$.city.coord.lon') AS FLOAT64) AS longitude,
    CAST(JSON_VALUE(raw_data, '$.city.coord.lat') AS FLOAT64) AS latitude,
    CAST(JSON_VALUE(raw_data, '$.city.timezone') AS INT64) AS timezone,
    FORMAT_DATETIME('%Y-%m-%d %H:%M:%S', DATETIME(TIMESTAMP_SECONDS(CAST(JSON_VALUE(raw_data, '$.city.sunrise') AS INT64) + CAST(JSON_VALUE(raw_data, '$.city.timezone') AS INT64)))) AS lever_soleil,
    FORMAT_DATETIME('%Y-%m-%d %H:%M:%S', DATETIME(TIMESTAMP_SECONDS(CAST(JSON_VALUE(raw_data, '$.city.sunset') AS INT64) + CAST(JSON_VALUE(raw_data, '$.city.timezone') AS INT64)))) AS coucher_soleil,
    CAST(JSON_VALUE(item, '$.main.temp') AS FLOAT64) AS temperature,
    CAST(JSON_VALUE(item, '$.main.temp_min') AS FLOAT64) AS temp_min,
    CAST(JSON_VALUE(item, '$.main.temp_max') AS FLOAT64) AS temp_max,
    CAST(JSON_VALUE(item, '$.main.feels_like') AS FLOAT64) AS feels_like,
    CAST(JSON_VALUE(item, '$.main.humidity') AS INT64) AS humidite,
    CAST(JSON_VALUE(item, '$.main.pressure') AS INT64) AS pression,
    CAST(JSON_VALUE(item, '$.main.sea_level') AS INT64) AS pression_mer,
    CAST(JSON_VALUE(item, '$.main.grnd_level') AS INT64) AS pression_sol,
    CAST(JSON_VALUE(item, '$.visibility') AS INT64) AS visibilite,
    JSON_VALUE(item, '$.weather[0].main') AS condition,
    JSON_VALUE(item, '$.weather[0].description') AS description,
    CAST(JSON_VALUE(item, '$.wind.speed') AS FLOAT64) AS vent_vitesse,
    CAST(JSON_VALUE(item, '$.wind.deg') AS INT64) AS vent_direction,
    CAST(JSON_VALUE(item, '$.wind.gust') AS FLOAT64) AS vent_rafale,
    CAST(JSON_VALUE(item, '$.clouds.all') AS INT64) AS nuages,
    CAST(JSON_VALUE(item, '$.pop') AS FLOAT64) AS probabilite_pluie,
    FORMAT_DATETIME('%Y-%m-%d %H:%M:%S', DATETIME(TIMESTAMP_SECONDS(CAST(JSON_VALUE(item, '$.dt') AS INT64) + CAST(JSON_VALUE(raw_data, '$.city.timezone') AS INT64)))) AS timestamp_prevision,
    FORMAT_DATETIME('%Y-%m-%d %H:%M:%S', DATETIME(TIMESTAMP_SECONDS(UNIX_SECONDS(timestamp) + CAST(JSON_VALUE(raw_data, '$.city.timezone') AS INT64)))) AS timestamp_insertion

  FROM {{ source('hackathon_openweather', 'raw_forecast') }},
  UNNEST(JSON_QUERY_ARRAY(raw_data, '$.list')) AS item
  WHERE raw_data IS NOT NULL
)

SELECT DISTINCT *
FROM base
WHERE ville IS NOT NULL
  AND temperature IS NOT NULL
  AND timestamp_prevision IS NOT NULL