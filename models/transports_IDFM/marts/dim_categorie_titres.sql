{{ config(materialized='table') }}

SELECT
    ROW_NUMBER() OVER (ORDER BY titre_normalise) AS id_titre,
    titre_normalise                               AS titre
FROM (
    SELECT DISTINCT
        CASE
            WHEN UPPER(TRIM(categorie_titre)) IN ('AMETHYSTE', 'AMÉTHYSTE')
                THEN 'Amethyste'
            WHEN UPPER(TRIM(categorie_titre)) IN ('NAVIGO', 'FORFAIT NAVIGO')
                THEN 'Forfait Navigo'
            WHEN UPPER(TRIM(categorie_titre)) IN ('IMAGINE R')
                THEN 'Imagine R'
            WHEN UPPER(TRIM(categorie_titre)) IN ('AUTRE TITRE', 'AUTRES TITRES')
                THEN 'Autres titres'
            WHEN UPPER(TRIM(categorie_titre)) IN ('NAVIGO JOUR')
                THEN 'Navigo Jour'
            WHEN UPPER(TRIM(categorie_titre)) IN ('NON DEFINI', 'NON DÉFINI')
                THEN 'Non Defini'
            WHEN UPPER(TRIM(categorie_titre)) IN ('FGT')
                THEN 'Forfait Gratuite Transport'
            WHEN UPPER(TRIM(categorie_titre)) IN ('TST')
                THEN 'Tarification Solidarite Transport'
            WHEN REGEXP_CONTAINS(TRIM(categorie_titre), r'(?i)Contrat Solidar.*Transport')
                THEN 'Contrat Solidarite Transport'
            ELSE TRIM(categorie_titre)
        END AS titre_normalise
    FROM (
        SELECT TRIM(categorie_titre) AS categorie_titre FROM {{ source('idfm', 'nb_surface_2023_t1') }}
        UNION DISTINCT
        SELECT TRIM(categorie_titre) FROM {{ source('idfm', 'nb_surface_2023_t2') }}
        UNION DISTINCT
        SELECT TRIM(categorie_titre) FROM {{ source('idfm', 'nb_surface_2023_t3') }}
        UNION DISTINCT
        SELECT TRIM(categorie_titre) FROM {{ source('idfm', 'nb_surface_2023_t4') }}
        UNION DISTINCT
        SELECT TRIM(categorie_titre) FROM {{ source('idfm', 'nb_surface_2024_t1') }}
        UNION DISTINCT
        SELECT TRIM(categorie_titre) FROM {{ source('idfm', 'nb_surface_2024_t2') }}
        UNION DISTINCT
        SELECT TRIM(categorie_titre) FROM {{ source('idfm', 'nb_surface_2024_t3') }}
    )
)