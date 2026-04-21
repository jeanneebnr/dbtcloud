{{
    config(materialized='table')
}}

SELECT
id_vehicule,
modele_vehicule,
id_type_vehicule,
immatriculation
FROM `centralisation_donnees_vtc.vehicules`
WHERE immatriculation IS NOT NULL