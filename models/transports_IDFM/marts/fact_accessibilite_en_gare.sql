{{ config(materialized='table') }}

SELECT 
    al.id_stop_idfm as id_stop_zda,
    aeg.niveau_accessibilite,
    aeg.note_accessibilite

FROM {{ref('stg_accessibilite_en_gare')}} as aeg
LEFT JOIN {{ref('stg_arrets_lignes')}} as al
ON aeg.id_stop_idfm = al.id_stop_idfm