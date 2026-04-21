
SELECT
id_vehicule,
modele_vehicule,
immatriculation,
id_type_vehicule
FROM `vtc-paris-493907.modele_en_etoile.vehicules`
WHERE immatriculation IS NOT NULL