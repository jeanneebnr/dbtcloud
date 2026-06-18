{{ config(materialized='table') }}

WITH union_nb_surface AS (
    SELECT * FROM {{ ref('stg_nb_surface_2023_t1') }}
    UNION ALL
    SELECT * FROM {{ ref('stg_nb_surface_2023_t2') }}
    UNION ALL
    SELECT * FROM {{ ref('stg_nb_surface_2023_t3') }}
    UNION ALL
    SELECT * FROM {{ ref('stg_nb_surface_2023_t4') }}
    UNION ALL
    SELECT * FROM {{ ref('stg_nb_surface_2024_t1') }}
    UNION ALL
    SELECT * FROM {{ ref('stg_nb_surface_2024_t2') }}
    UNION ALL
    SELECT * FROM {{ ref('stg_nb_surface_2024_t3') }}
)

SELECT
    dl.id_ligne                                                         AS id_ligne,
    CONCAT(
        LPAD(CAST(SAFE_CAST(TRIM(ns.id_transporteur_stif) AS INT64) AS STRING), 3, '0'),
        LPAD(CAST(SAFE_CAST(TRIM(ns.id_reseau_stif)       AS INT64) AS STRING), 3, '0'),
        LPAD(CAST(SAFE_CAST(TRIM(ns.id_ligne_stif)        AS INT64) AS STRING), 3, '0')
    )                                                                   AS private_code,
    ns.date,
    dc.id_titre                                                         AS id_titre,
    ns.validations_nb

FROM union_nb_surface AS ns

LEFT JOIN {{ ref('dim_lignes') }} AS dl
    ON CONCAT(
        LPAD(CAST(SAFE_CAST(TRIM(ns.id_transporteur_stif) AS INT64) AS STRING), 3, '0'),
        LPAD(CAST(SAFE_CAST(TRIM(ns.id_reseau_stif)       AS INT64) AS STRING), 3, '0'),
        LPAD(CAST(SAFE_CAST(TRIM(ns.id_ligne_stif)        AS INT64) AS STRING), 3, '0')
    ) = dl.private_code

LEFT JOIN {{ ref('dim_categorie_titres') }} AS dc
    ON CASE
        WHEN UPPER(TRIM(ns.categorie_titre)) IN ('AMETHYSTE', 'AMÉTHYSTE')
            THEN 'Amethyste'
        WHEN UPPER(TRIM(ns.categorie_titre)) IN ('NAVIGO', 'FORFAIT NAVIGO')
            THEN 'Forfait Navigo'
        WHEN UPPER(TRIM(ns.categorie_titre)) IN ('IMAGINE R')
            THEN 'Imagine R'
        WHEN UPPER(TRIM(ns.categorie_titre)) IN ('AUTRE TITRE', 'AUTRES TITRES')
            THEN 'Autres titres'
        WHEN UPPER(TRIM(ns.categorie_titre)) IN ('NAVIGO JOUR')
            THEN 'Navigo Jour'
        WHEN UPPER(TRIM(ns.categorie_titre)) IN ('NON DEFINI', 'NON DÉFINI')
            THEN 'Non Defini'
        WHEN UPPER(TRIM(ns.categorie_titre)) IN ('FGT')
            THEN 'Forfait Gratuite Transport'
        WHEN UPPER(TRIM(ns.categorie_titre)) IN ('TST')
            THEN 'Tarification Solidarite Transport'
        ELSE TRIM(ns.categorie_titre)
    END = dc.titre