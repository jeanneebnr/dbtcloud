{{
    config(materialized='table')
}}

SELECT
id_segment,
nom_segment
FROM `vtc-paris-493907.modele_en_etoile.segments_clients`