{{config(materialized='table')}}

WITH source as (
    SELECT
        *,
        '2023_s1' as periode
    FROM {{ ref('stg_profil_surface_2023_s1') }}
    UNION ALL
    SELECT
        *,
        '2023_s2' as periode
    FROM {{ ref('stg_profil_surface_2023_s2') }}
    UNION ALL
    SELECT
        *,
        '2024_s1' as periode
    FROM {{ ref('stg_profil_surface_2024_s1') }}
    UNION ALL
    SELECT
       *,
       '2024_t3' as periode
    FROM {{ ref('stg_profil_surface_2024_t3') }}

)

SELECT
    dl.id_ligne,
    CONCAT(
    LPAD(CAST(SAFE_CAST(TRIM(pf.id_transporteur_stif) AS INT64) AS STRING), 3, '0'),
    LPAD(CAST(SAFE_CAST(TRIM(pf.id_reseau_stif) AS INT64) AS STRING), 3, '0'),
    LPAD(CAST(SAFE_CAST(TRIM(pf.id_ligne_stif) AS INT64) AS STRING), 3, '0')) as private_code,
    pf.categorie_jour,
    pf.heure,
    pf.periode,
    pf.validations_pct

FROM source pf
LEFT JOIN {{ ref('dim_lignes') }} AS dl
    ON CONCAT(
    LPAD(CAST(SAFE_CAST(TRIM(pf.id_transporteur_stif) AS INT64) AS STRING), 3, '0'),
    LPAD(CAST(SAFE_CAST(TRIM(pf.id_reseau_stif) AS INT64) AS STRING), 3, '0'),
    LPAD(CAST(SAFE_CAST(TRIM(pf.id_ligne_stif) AS INT64) AS STRING), 3, '0')
) = dl.private_code
ORDER BY id_ligne, categorie_jour, periode, heure