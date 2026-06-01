SELECT
    cast(time AS date) as date,

    CAST(temperature_2m_mean AS FLOAT64) AS temperature_2m_mean,
    CAST(temperature_2m_max AS FLOAT64) AS temperature_2m_max,
    CAST(temperature_2m_min AS FLOAT64) AS temperature_2m_min,

    CAST(precipitation_sum AS FLOAT64) AS precipitation_combo_pluie_neige,
    CAST(rain_sum AS FLOAT64) AS somme_pluie,
    CAST(snowfall_sum AS FLOAT64) AS somme_neige,
    CAST(precipitation_hours AS FLOAT64) AS precipitation_par_heure,

    CAST(windspeed_10m_max AS FLOAT64) AS windspeed_10m_max,
    CAST(windgusts_10m_max AS FLOAT64) AS windgusts_10m_max,
    CAST(winddirection_10m_dominant AS FLOAT64) AS winddirection_10m_dominant,

    CAST(weathercode AS INT64) AS weathercode,

    CAST(year AS INT64) AS annee,
    CAST(month AS INT64) AS mois,
    CAST(day_of_week AS INT64) AS indice_jour,
    CAST(day_name AS STRING) AS jour_semaine,
    CAST(week AS INT64) AS semaine,
    CAST(quarter AS INT64) AS trimestre,

    CAST(temp_category AS STRING) AS temp_categorie,
    CAST(rain_category AS STRING) AS pluie_categorie,
    CAST(wind_category AS STRING) AS vent_categorie,

    CAST(is_rainy AS BOOL) AS pluie,
    CAST(is_snowy AS BOOL) AS neige,
    CAST(is_windy AS BOOL) AS vent,
    CAST(is_extreme AS BOOL) AS extreme,

    CAST(weather_description AS STRING) AS description_temp

FROM {{ source('idfm', 'meteo_paris_2023_2024') }}