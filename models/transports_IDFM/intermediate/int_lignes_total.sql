{{ config(materialized='table') }}

WITH stif AS (
    SELECT private_code, id_ligne_stif, libelle_ligne
    FROM {{ ref('int_lignes_stif') }}
),

idfm AS (
    SELECT id_ligne_idfm, libelle_ligne
    FROM {{ ref('int_lignes_idfm') }}
),

ref AS (
    SELECT privatecode, id_ligne_idfm, libelle_ligne
    FROM {{ ref('stg_lignes_referentiel') }}
),

joined AS (
    SELECT
        ref.privatecode as private_code,
        ref.id_ligne_idfm,
        stif.id_ligne_stif,
        stif.libelle_ligne AS libelle_stif,
        idfm.libelle_ligne AS libelle_idfm,
        COALESCE(ref.libelle_ligne, idfm.libelle_ligne, stif.libelle_ligne) AS libelle_ligne,
        CASE
            WHEN stif.id_ligne_stif IS NOT NULL
             AND idfm.id_ligne_idfm IS NOT NULL THEN 'BOTH'
            WHEN stif.id_ligne_stif IS NOT NULL THEN 'STIF_ONLY'
            WHEN idfm.id_ligne_idfm IS NOT NULL THEN 'IDFM_ONLY'
            ELSE 'ORPHAN'
        END AS source_status,
        CASE WHEN stif.id_ligne_stif IS NOT NULL THEN TRUE ELSE FALSE END AS has_stif,
        CASE WHEN idfm.id_ligne_idfm IS NOT NULL THEN TRUE ELSE FALSE END AS has_idfm
    FROM ref
    LEFT JOIN stif ON ref.privatecode = stif.private_code
    LEFT JOIN idfm ON ref.id_ligne_idfm = idfm.id_ligne_idfm
),

stif_only AS (
    SELECT
        stif.private_code,
        CAST(NULL AS STRING) AS id_ligne_idfm,
        stif.id_ligne_stif,
        stif.libelle_ligne AS libelle_stif,
        CAST(NULL AS STRING) AS libelle_idfm,
        stif.libelle_ligne AS libelle_ligne,
        'STIF_ONLY' AS source_status,
        TRUE AS has_stif,
        FALSE AS has_idfm
    FROM stif
    WHERE NOT EXISTS (
        SELECT 1 FROM ref
        WHERE ref.privatecode = stif.private_code
    )
),

idfm_only AS (
    SELECT
        CAST(NULL AS STRING) AS private_code,
        idfm.id_ligne_idfm,
        CAST(NULL AS INT64) AS id_ligne_stif,
        CAST(NULL AS STRING) AS libelle_stif,
        idfm.libelle_ligne AS libelle_idfm,
        idfm.libelle_ligne AS libelle_ligne,
        'IDFM_ONLY' AS source_status,
        FALSE AS has_stif,
        TRUE AS has_idfm
    FROM idfm
    WHERE NOT EXISTS (
        SELECT 1 FROM ref
        WHERE ref.id_ligne_idfm = idfm.id_ligne_idfm
    )
)

SELECT * FROM joined
UNION ALL
SELECT * FROM stif_only
UNION ALL
SELECT * FROM idfm_only

ORDER BY id_ligne_idfm