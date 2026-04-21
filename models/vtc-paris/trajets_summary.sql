{{ config(materialized='table')}}

SELECT
  sc.nom_segment,
  tv.nom_type_vehicule,
  COUNT(t.id_trajet) AS nombre_trajets,
  ROUND(SUM(t.montant_total), 2) AS total_revenus
FROM `vtc-paris-493907.modele_en_etoile.trajets` t
JOIN `vtc-paris-493907.modele_en_etoile.clients` c ON t.id_client = c.id_client
JOIN `vtc-paris-493907.modele_en_etoile.segments_clients` sc ON c.id_segment = sc.id_segment
JOIN `vtc-paris-493907.modele_en_etoile.vehicules` v ON t.id_vehicule = v.id_vehicule
JOIN `vtc-paris-493907.modele_en_etoile.types_vehicules` tv ON v.id_type_vehicule = tv.id_type_vehicule
GROUP BY sc.nom_segment, tv.nom_type_vehicule
ORDER BY total_revenus DESC