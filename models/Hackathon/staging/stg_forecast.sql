WITH transform AS (
  SELECT
    JSON_VALUE(raw_data, '$.city.name') AS ville,
    JSON_VALUE(raw_data, '$.city.country') AS pays,

    CAST(JSON_VALUE(raw_data, '$.city.coord.lon') AS FLOAT64) AS longitude,
    CAST(JSON_VALUE(raw_data, '$.city.coord.lat') AS FLOAT64) AS latitude,
    CAST(JSON_VALUE(raw_data, '$.city.timezone') AS INT64) AS timezone,

    FORMAT_DATETIME('%Y-%m-%d %H:%M:%S',
      DATETIME(TIMESTAMP_SECONDS(
        CAST(JSON_VALUE(raw_data, '$.city.sunrise') AS INT64)
        + CAST(JSON_VALUE(raw_data, '$.city.timezone') AS INT64)
      ))
    ) AS lever_soleil,

    FORMAT_DATETIME('%Y-%m-%d %H:%M:%S',
      DATETIME(TIMESTAMP_SECONDS(
        CAST(JSON_VALUE(raw_data, '$.city.sunset') AS INT64)
        + CAST(JSON_VALUE(raw_data, '$.city.timezone') AS INT64)
      ))
    ) AS coucher_soleil,

    CAST(JSON_VALUE(item, '$.main.temp') AS FLOAT64) AS temperature,
    CAST(JSON_VALUE(item, '$.main.temp_min') AS FLOAT64) AS temp_min,
    CAST(JSON_VALUE(item, '$.main.temp_max') AS FLOAT64) AS temp_max,

    ROUND(
      CAST(JSON_VALUE(item, '$.main.temp_max') AS FLOAT64)
      - CAST(JSON_VALUE(item, '$.main.temp_min') AS FLOAT64),
      2
    ) AS amplitude_thermique,

    CAST(JSON_VALUE(item, '$.main.feels_like') AS FLOAT64) AS feels_like,
    CAST(JSON_VALUE(item, '$.main.humidity') AS INT64) AS humidite,
    CAST(JSON_VALUE(item, '$.main.pressure') AS INT64) AS pression,
    CAST(JSON_VALUE(item, '$.main.sea_level') AS INT64) AS pression_mer,
    CAST(JSON_VALUE(item, '$.main.grnd_level') AS INT64) AS pression_sol,
    CAST(JSON_VALUE(item, '$.visibility') AS INT64) AS visibilite,
    ROUND(CAST(JSON_VALUE(item, '$.visibility') AS INT64) / 1000.0, 2) AS visibilite_km,

    JSON_VALUE(item, '$.weather[0].main') AS condition,
    JSON_VALUE(item, '$.weather[0].description') AS description,

    CAST(JSON_VALUE(item, '$.wind.speed') AS FLOAT64) AS vent_vitesse,
    ROUND(CAST(JSON_VALUE(item, '$.wind.speed') AS FLOAT64) * 3.6, 2) AS vent_vitesse_kmh,
    CAST(JSON_VALUE(item, '$.wind.deg') AS INT64) AS vent_direction,

    CASE
      WHEN CAST(JSON_VALUE(item, '$.wind.deg') AS INT64) >= 337.5 OR CAST(JSON_VALUE(item, '$.wind.deg') AS INT64) < 22.5 THEN 'Nord'
      WHEN CAST(JSON_VALUE(item, '$.wind.deg') AS INT64) >= 22.5 AND CAST(JSON_VALUE(item, '$.wind.deg') AS INT64) < 67.5 THEN 'Nord-Est'
      WHEN CAST(JSON_VALUE(item, '$.wind.deg') AS INT64) >= 67.5 AND CAST(JSON_VALUE(item, '$.wind.deg') AS INT64) < 112.5 THEN 'Est'
      WHEN CAST(JSON_VALUE(item, '$.wind.deg') AS INT64) >= 112.5 AND CAST(JSON_VALUE(item, '$.wind.deg') AS INT64) < 157.5 THEN 'Sud-Est'
      WHEN CAST(JSON_VALUE(item, '$.wind.deg') AS INT64) >= 157.5 AND CAST(JSON_VALUE(item, '$.wind.deg') AS INT64) < 202.5 THEN 'Sud'
      WHEN CAST(JSON_VALUE(item, '$.wind.deg') AS INT64) >= 202.5 AND CAST(JSON_VALUE(item, '$.wind.deg') AS INT64) < 247.5 THEN 'Sud-Ouest'
      WHEN CAST(JSON_VALUE(item, '$.wind.deg') AS INT64) >= 247.5 AND CAST(JSON_VALUE(item, '$.wind.deg') AS INT64) < 292.5 THEN 'Ouest'
      WHEN CAST(JSON_VALUE(item, '$.wind.deg') AS INT64) >= 292.5 AND CAST(JSON_VALUE(item, '$.wind.deg') AS INT64) < 337.5 THEN 'Nord-Ouest'
    END AS vent_direction_cardinale,

    CAST(JSON_VALUE(item, '$.wind.gust') AS FLOAT64) AS vent_rafale,
    CAST(JSON_VALUE(item, '$.clouds.all') AS INT64) AS nuages,
    CAST(JSON_VALUE(item, '$.pop') AS FLOAT64) AS probabilite_pluie,

    TIMESTAMP_SECONDS(CAST(JSON_VALUE(item, '$.dt') AS INT64)) AS timestamp_prevision,

    CURRENT_TIMESTAMP() AS timestamp_insertion

  FROM {{ source('hackathon_openweather', 'raw_forecast') }},
  UNNEST(JSON_QUERY_ARRAY(raw_data, '$.list')) AS item
  WHERE raw_data IS NOT NULL
),

enriched AS (
  SELECT *,
CASE
  WHEN EXTRACT(HOUR FROM timestamp_prevision) BETWEEN 0 AND 5 THEN 0
  WHEN EXTRACT(HOUR FROM timestamp_prevision) BETWEEN 6 AND 8 THEN 20
  WHEN EXTRACT(HOUR FROM timestamp_prevision) BETWEEN 9 AND 17 THEN 30
  WHEN EXTRACT(HOUR FROM timestamp_prevision) BETWEEN 18 AND 21 THEN 20
  WHEN EXTRACT(HOUR FROM timestamp_prevision) BETWEEN 22 AND 23 THEN 5
END AS score_periode,

CASE
  WHEN temperature BETWEEN 15 AND 25 THEN 20
  WHEN temperature BETWEEN 10 AND 30 THEN 14
  ELSE 8
END AS score_temperature,

CASE
  WHEN probabilite_pluie > 0.8 THEN 0
  WHEN probabilite_pluie > 0.6 THEN 4
  WHEN probabilite_pluie > 0.3 THEN 10
  ELSE 20
END AS score_pluie,

CASE
  WHEN vent_vitesse > 10 THEN 2
  WHEN vent_vitesse > 5 THEN 6
  ELSE 10
END AS score_vent,

CASE
  WHEN nuages > 80 THEN 5
  WHEN nuages > 50 THEN 7
  ELSE 10
END AS score_nuages,

CASE
  WHEN visibilite < 2000 THEN 2
  WHEN visibilite < 5000 THEN 6
  ELSE 10
END AS score_visibilite,
    
  FROM transform
),

indice AS (
  SELECT *,
    score_temperature + score_pluie + score_vent + score_visibilite + score_nuages AS indice_mobilite
  FROM enriched
),

final_enriched AS (
  SELECT *,
    CASE
      WHEN indice_mobilite >= 80 THEN 'Très bonne mobilité'
      WHEN indice_mobilite >= 60 THEN 'Bonne mobilité'
      WHEN indice_mobilite >= 40 THEN 'Mobilité modérée'
      ELSE 'Mobilité faible'
    END AS categorie_mobilite
  FROM indice
),

clean AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY ville, timestamp_prevision
      ORDER BY timestamp_prevision DESC
    ) AS rn
  FROM final_enriched
  WHERE ville IS NOT NULL
    AND temperature IS NOT NULL
    AND timestamp_prevision IS NOT NULL
)

SELECT * EXCEPT(rn)
FROM clean
WHERE rn = 1