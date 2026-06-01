{{ config(materialized='table') }}


WITH stif AS (

    SELECT
        id_zdc,
        ANY_VALUE(private_code_arret) AS private_code_arret,
        ANY_VALUE(libelle_arret) AS libelle_arret_stif

    FROM {{ ref('int_arrets_stif') }}
    GROUP BY id_zdc

),

idfm AS (

    SELECT
        id_zdc,
        ANY_VALUE(libelle_arret) AS libelle_arret_idfm

    FROM {{ ref('int_arrets_idfm') }}
    GROUP BY id_zdc

)

SELECT

    COALESCE(stif.id_zdc, idfm.id_zdc) AS id_zdc,
    CASE
        WHEN stif.id_zdc IS NOT NULL
        AND idfm.id_zdc IS NOT NULL
            THEN 'MIXED'

        WHEN stif.id_zdc IS NOT NULL
            THEN 'STIF'

        WHEN idfm.id_zdc IS NOT NULL
            THEN 'IDFM'

        ELSE 'UNKNOWN'
    END AS zdc_origin,
    stif.private_code_arret,
    stif.libelle_arret_stif,
    idfm.libelle_arret_idfm,

    CASE
        WHEN stif.id_zdc IS NOT NULL
         AND idfm.id_zdc IS NOT NULL
            THEN 'BOTH'

        WHEN stif.id_zdc IS NOT NULL
            THEN 'STIF_ONLY'

        WHEN idfm.id_zdc IS NOT NULL
            THEN 'IDFM_ONLY'

        ELSE 'ORPHAN'
    END AS source_status

FROM stif

FULL OUTER JOIN idfm
    ON stif.id_zdc = idfm.id_zdc