{{ config(materialized='table') }}

SELECT DISTINCT

    al.id_stop_idfm AS id_arret_zda,

    ref.id_zdc AS id_arret_zdc,

    dl.id_ligne

FROM {{ ref('stg_arrets_lignes') }} al

LEFT JOIN {{ ref('stg_arrets_referentiel') }} ref
    ON al.id_stop_idfm = ref.id_arret_idfm

LEFT JOIN {{ ref('dim_lignes') }} dl
    ON al.id_ligne_idfm = dl.id_ligne_idfm

WHERE
    al.id_stop_idfm IS NOT NULL
    AND dl.id_ligne IS NOT NULL

ORDER BY id_arret_zdc DESC