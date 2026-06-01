{{ config(materialized='table') }}

WITH all_facts AS (

    SELECT
        SAFE_CAST(TRIM(id_transporteur_stif) AS INT64) AS id_transporteur_stif,
        SAFE_CAST(TRIM(id_reseau_stif) AS INT64)       AS id_reseau_stif,
        SAFE_CAST(TRIM(id_arret_stif) AS INT64)        AS id_arret_stif,
        TRIM(id_zone_arret)                            AS id_zdc,
        libelle_arret
    FROM {{ ref('stg_profil_fer_2023_s1') }}

    UNION ALL

    SELECT
        SAFE_CAST(TRIM(id_transporteur_stif) AS INT64),
        SAFE_CAST(TRIM(id_reseau_stif) AS INT64),
        SAFE_CAST(TRIM(id_arret_stif) AS INT64),
        TRIM(id_zone_arret),
        libelle_arret
    FROM {{ ref('stg_profil_fer_2023_s2') }}

    UNION ALL

    SELECT
        SAFE_CAST(TRIM(id_transporteur_stif) AS INT64),
        SAFE_CAST(TRIM(id_reseau_stif) AS INT64),
        SAFE_CAST(TRIM(id_arret_stif) AS INT64),
        TRIM(id_zone_arret),
        libelle_arret
    FROM {{ ref('stg_profil_fer_2024_s1') }}

    UNION ALL

    SELECT
        SAFE_CAST(TRIM(id_transporteur_stif) AS INT64),
        SAFE_CAST(TRIM(id_reseau_stif) AS INT64),
        SAFE_CAST(TRIM(id_arret_stif) AS INT64),
        TRIM(id_zone_arret),
        libelle_arret
    FROM {{ ref('stg_profil_fer_2024_t3') }}

),

filtered AS (

    SELECT
        CONCAT(
            LPAD(CAST(id_transporteur_stif AS STRING), 3, '0'),
            LPAD(CAST(id_reseau_stif AS STRING), 3, '0'),
            LPAD(CAST(id_arret_stif AS STRING), 6, '0')
        ) AS private_code_arret,
        id_transporteur_stif,
        id_reseau_stif,
        id_arret_stif,
        id_zdc,
        libelle_arret
    FROM all_facts
    WHERE id_transporteur_stif IS NOT NULL
      AND id_reseau_stif IS NOT NULL
      AND id_arret_stif IS NOT NULL
      AND id_transporteur_stif >= 0
      AND id_reseau_stif >= 0
      AND id_arret_stif >= 0

)

SELECT
    private_code_arret,
    id_transporteur_stif,
    id_reseau_stif,
    id_arret_stif,
    id_zdc,
    libelle_arret
FROM filtered
QUALIFY ROW_NUMBER() OVER (PARTITION BY id_zdc ORDER BY LENGTH(libelle_arret) DESC) = 1