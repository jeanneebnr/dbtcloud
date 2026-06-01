{{ config(materialized='table') }}

WITH source AS (
    SELECT *,
    '2024_s1' AS periode
    FROM {{ ref('stg_profil_fer_2024_s1') }}
    UNION ALL
    SELECT *,
    '2024_t3' AS periode
    FROM {{ ref('stg_profil_fer_2024_t3') }}
    UNION ALL
    SELECT *,
    '2023_s1' AS periode
    FROM {{ ref('stg_profil_fer_2023_s1') }}
    UNION ALL
    SELECT *,
    '2023_s2' AS periode
    FROM {{ ref('stg_profil_fer_2023_s2') }}

)

SELECT
    daz.id_arret,
    nf.categorie_jour,
    nf.heure,
    nf.periode,
    nf.validations_pct

FROM source nf
JOIN {{ref('dim_arrets_zdc')}}  daz
ON nf.id_zone_arret = daz.id_zdc
ORDER BY id_arret, categorie_jour, periode, heure
