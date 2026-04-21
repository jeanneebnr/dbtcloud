  
    SELECT
id_client,
nom_client,
prenom_client,
email_client,
id_segment
FROM `vtc-paris-493907.modele_en_etoile.clients`
WHERE email_client IS NOT NULL