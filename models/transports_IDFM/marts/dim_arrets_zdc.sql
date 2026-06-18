{{ config(materialized='table') }}

WITH arrets_lignes_zdc AS (

    SELECT
        ref.id_zdc,

        ANY_VALUE(al.ville) AS ville,
        ANY_VALUE(al.code_postal) AS code_postal,

        ANY_VALUE(al.latitude) AS latitude,
        ANY_VALUE(al.longitude) AS longitude

    FROM {{ ref('stg_arrets_lignes') }} al

    LEFT JOIN {{ ref('stg_arrets_referentiel') }} ref
        ON al.id_stop_idfm = ref.id_arret_idfm

    WHERE ref.id_zdc IS NOT NULL

    GROUP BY ref.id_zdc

)

SELECT

    ROW_NUMBER() OVER (ORDER BY arr_total.id_zdc) AS id_arret,

    arr_total.id_zdc,

    arr_total.zdc_origin,

    arr_total.private_code_arret as private_code_arret,

    COALESCE(
        arr_total.libelle_arret_stif,
        arr_total.libelle_arret_idfm
    ) AS libelle_arret,

    al.ville,
    al.code_postal,

    al.latitude,
    al.longitude

FROM {{ ref('int_arrets_total') }} arr_total

LEFT JOIN arrets_lignes_zdc al
    ON arr_total.id_zdc = al.id_zdc