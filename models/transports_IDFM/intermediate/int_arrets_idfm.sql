{{ config(materialized='table') }}

WITH arrets_lignes AS (

    SELECT
        al.id_stop_idfm AS id_arret_idfm,
        ref.id_zdc,

        al.libelle_arret,
        al.ville,
        al.code_postal,

        al.latitude,
        al.longitude,

        al.type_transport,
        al.reservation

    FROM {{ ref('stg_arrets_lignes') }} al

    LEFT JOIN {{ ref('stg_arrets_referentiel') }} ref
        ON al.id_stop_idfm = ref.id_arret_idfm

),

accessibilite AS (

    SELECT
        id_stop_idfm AS id_arret_idfm,
        niveau_accessibilite,
        note_accessibilite

    FROM {{ ref('stg_accessibilite_en_gare') }}

)

SELECT

    al.id_arret_idfm,

    COALESCE(al.id_zdc, 'UNMAPPED_ZDC') AS id_zdc,

    al.libelle_arret,
    al.ville,
    al.code_postal,

    al.latitude,
    al.longitude,

    al.type_transport,
    al.reservation,

    acc.niveau_accessibilite,
    acc.note_accessibilite

FROM arrets_lignes al

LEFT JOIN accessibilite acc
    ON al.id_arret_idfm = acc.id_arret_idfm

QUALIFY ROW_NUMBER() OVER (
    PARTITION BY COALESCE(al.id_zdc, 'UNMAPPED_ZDC')
    ORDER BY LENGTH(al.libelle_arret) DESC
) = 1