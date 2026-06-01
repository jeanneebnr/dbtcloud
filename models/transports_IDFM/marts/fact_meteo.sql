{{ config(materialized='table') }}

SELECT
    ROW_NUMBER() OVER (ORDER BY CAST(time AS DATE)) AS id_meteo,
    CAST(time AS DATE)                              AS date,
    CAST(temperature_2m_mean AS FLOAT64)            AS temp_moy,
    CAST(temperature_2m_max AS FLOAT64)             AS temp_max,
    CAST(temperature_2m_min AS FLOAT64)             AS temp_min,
    CAST(precipitation_sum AS FLOAT64)              AS precipitation_sum,
    CAST(rain_sum AS FLOAT64)                       AS pluie_somme,
    CAST(snowfall_sum AS FLOAT64)                   AS neige_somme,
    CAST(precipitation_hours AS FLOAT64)            AS pluie_heure,
    CAST(windspeed_10m_max AS FLOAT64)              AS vent_vitesse,
    CAST(windgusts_10m_max AS FLOAT64)              AS vent_rafale,
    CAST(winddirection_10m_dominant AS INT64)       AS vent_direction,
    CAST(weathercode AS INT64)                      AS code_meteo,
    CAST(temp_category AS STRING)                   AS temp_categorie,
    CAST(rain_category AS STRING)                   AS pluie_categorie,
    CAST(wind_category AS STRING)                   AS vent_categorie,
    CAST(is_rainy AS BOOL)                          AS is_rainy,
    CAST(is_snowy AS BOOL)                          AS is_snowy,
    CAST(is_windy AS BOOL)                          AS is_windy,
    CAST(is_extreme AS BOOL)                        AS is_extrem,
    CAST(weather_description AS STRING)             AS description_meteo

FROM {{ source('idfm', 'meteo_paris_2023_2024') }}