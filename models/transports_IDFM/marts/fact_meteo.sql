{{ config(materialized='table') }}

SELECT
    ROW_NUMBER() OVER (ORDER BY CAST(date AS DATE)) AS id_meteo,
    CAST(date AS DATE) AS date,
    CAST(temperature_2m_mean AS FLOAT64) AS temp_moy,
    CAST(temperature_2m_max AS FLOAT64) AS temp_max,
    CAST(temperature_2m_min AS FLOAT64) AS temp_min,
    CAST(precipitation_combo_pluie_neige AS FLOAT64) AS precipitation_sum,
    CAST(somme_pluie AS FLOAT64) AS pluie_somme,
    CAST(somme_neige AS FLOAT64) AS neige_somme,
    CAST(precipitation_par_heure AS FLOAT64) AS pluie_heure,
    CAST(windspeed_10m_max AS FLOAT64) AS vent_vitesse,
    CAST(windgusts_10m_max AS FLOAT64) AS vent_rafale,
    CAST(winddirection_10m_dominant AS INT64) AS vent_direction,
    CAST(weathercode AS INT64) AS code_meteo,
    CAST(temp_categorie AS STRING) AS temp_categorie,
    CAST(pluie_categorie AS STRING) AS pluie_categorie,
    CAST(vent_categorie AS STRING) AS vent_categorie,
    CAST(pluie AS BOOL) AS is_rainy,
    CAST(neige AS BOOL) AS is_snowy,
    CAST(vent AS BOOL) AS is_windy,
    CAST(extreme AS BOOL) AS is_extrem,
    CAST(description_temp AS STRING) AS description_meteo

FROM stg_meteo_paris_2023_2024