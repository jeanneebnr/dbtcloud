WITH transform AS (
  SELECT
    JSON_VALUE(raw_data, '$.name') AS ville,
    JSON_VALUE(raw_data, '$.sys.country') AS pays,
    CAST(JSON_VALUE(raw_data, '$.coord.lon') AS FLOAT64) AS longitude,
    CAST(JSON_VALUE(raw_data, '$.coord.lat') AS FLOAT64) AS latitude,
    CAST(JSON_VALUE(raw_data, '$.main.temp') AS FLOAT64) AS temperature,
    CAST(JSON_VALUE(raw_data, '$.main.temp_min') AS FLOAT64) AS temp_min,
    CAST(JSON_VALUE(raw_data, '$.main.temp_max') AS FLOAT64) AS temp_max,
    ROUND(CAST(JSON_VALUE(raw_data, '$.main.temp_max') AS FLOAT64) - CAST(JSON_VALUE(raw_data, '$.main.temp_min') AS FLOAT64), 2) AS amplitude_thermique,
    CAST(JSON_VALUE(raw_data, '$.main.feels_like') AS FLOAT64) AS feels_like,
    CAST(JSON_VALUE(raw_data, '$.main.humidity') AS INT64) AS humidite,
    CAST(JSON_VALUE(raw_data, '$.main.pressure') AS INT64) AS pression,
    CAST(JSON_VALUE(raw_data, '$.main.sea_level') AS INT64) AS pression_mer,
    CAST(JSON_VALUE(raw_data, '$.main.grnd_level') AS INT64) AS pression_sol,
    CAST(JSON_VALUE(raw_data, '$.visibility') AS INT64) AS visibilite,
    JSON_VALUE(raw_data, '$.weather[0].main') AS condition,
    JSON_VALUE(raw_data, '$.weather[0].description') AS description,
    CAST(JSON_VALUE(raw_data, '$.wind.speed') AS FLOAT64) AS vent_vitesse,
    CAST(JSON_VALUE(raw_data, '$.wind.deg') AS INT64) AS vent_direction,
    CASE
        WHEN CAST(JSON_VALUE(raw_data, '$.wind.deg') AS INT64) >= 337.5 OR CAST(JSON_VALUE(raw_data, '$.wind.deg') AS INT64) < 22.5 THEN 'Nord'
        WHEN CAST(JSON_VALUE(raw_data, '$.wind.deg') AS INT64) >= 22.5 AND CAST(JSON_VALUE(raw_data, '$.wind.deg') AS INT64) < 67.5 THEN 'Nord-Est'
        WHEN CAST(JSON_VALUE(raw_data, '$.wind.deg') AS INT64) >= 67.5 AND CAST(JSON_VALUE(raw_data, '$.wind.deg') AS INT64) < 112.5 THEN 'Est'
        WHEN CAST(JSON_VALUE(raw_data, '$.wind.deg') AS INT64) >= 112.5 AND CAST(JSON_VALUE(raw_data, '$.wind.deg') AS INT64) < 157.5 THEN 'Sud-Est'
        WHEN CAST(JSON_VALUE(raw_data, '$.wind.deg') AS INT64) >= 157.5 AND CAST(JSON_VALUE(raw_data, '$.wind.deg') AS INT64) < 202.5 THEN 'Sud'
        WHEN CAST(JSON_VALUE(raw_data, '$.wind.deg') AS INT64) >= 202.5 AND CAST(JSON_VALUE(raw_data, '$.wind.deg') AS INT64) < 247.5 THEN 'Sud-Ouest'
        WHEN CAST(JSON_VALUE(raw_data, '$.wind.deg') AS INT64) >= 247.5 AND CAST(JSON_VALUE(raw_data, '$.wind.deg') AS INT64) < 292.5 THEN 'Ouest'
        WHEN CAST(JSON_VALUE(raw_data, '$.wind.deg') AS INT64) >= 292.5 AND CAST(JSON_VALUE(raw_data, '$.wind.deg') AS INT64) < 337.5 THEN 'Nord-Ouest'
    END AS vent_direction_cardinale,
    CAST(JSON_VALUE(raw_data, '$.clouds.all') AS INT64) AS nuages,
    FORMAT_DATETIME('%Y-%m-%d %H:%M:%S', DATETIME(TIMESTAMP_SECONDS(CAST(JSON_VALUE(raw_data, '$.sys.sunrise') AS INT64) + CAST(JSON_VALUE(raw_data, '$.timezone') AS INT64)))) AS lever_soleil,
    FORMAT_DATETIME('%Y-%m-%d %H:%M:%S', DATETIME(TIMESTAMP_SECONDS(CAST(JSON_VALUE(raw_data, '$.sys.sunset') AS INT64) + CAST(JSON_VALUE(raw_data, '$.timezone') AS INT64)))) AS coucher_soleil,
    FORMAT_DATETIME('%Y-%m-%d %H:%M:%S', DATETIME(TIMESTAMP_SECONDS(CAST(JSON_VALUE(raw_data, '$.dt') AS INT64) + CAST(JSON_VALUE(raw_data, '$.timezone') AS INT64)))) AS timestamp_mesure,
    FORMAT_DATETIME('%Y-%m-%d %H:%M:%S', DATETIME(TIMESTAMP_SECONDS(UNIX_SECONDS(timestamp) + CAST(JSON_VALUE(raw_data, '$.timezone') AS INT64)))) AS timestamp_insertion

  FROM {{ source('hackathon_openweather', 'raw_weather') }}
  WHERE raw_data IS NOT NULL
),

clean AS (
  SELECT *,
    ROW_NUMBER() OVER (
    PARTITION BY ville,
    DATE(PARSE_DATETIME('%Y-%m-%d %H:%M:%S', timestamp_mesure)),
    EXTRACT(HOUR FROM PARSE_DATETIME('%Y-%m-%d %H:%M:%S', timestamp_mesure))
    ORDER BY timestamp_insertion DESC
    ) AS rn
  FROM transform
  WHERE ville IS NOT NULL
    AND temperature IS NOT NULL
    AND timestamp_mesure IS NOT NULL
)

SELECT * EXCEPT(rn)
FROM clean
WHERE rn = 1