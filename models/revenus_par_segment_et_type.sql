WITH trajets_clean AS (
SELECT
t.id_trajet,
t.id_client,
t.id_vehicule,
t.montant_total
FROM `vtc-paris-493907.modele_en_etoile.trajets` t
)

SELECT
scs.nom_segment,
tvs.nom_type_vehicule,
COUNT(tc.id_trajet) AS nombre_trajets,
SUM(tc.montant_total) AS total_revenus
FROM trajets_clean tc
JOIN {{ ref('stg_clients') }} c ON tc.id_client = c.id_client
JOIN {{ ref('stg_segments_clients') }} scs ON c.id_segment =
scs.id_segment
JOIN {{ ref('stg_vehicules') }} v ON tc.id_vehicule = v.id_vehicule
JOIN {{ ref('stg_types_vehicules') }} tvs ON v.id_type_vehicule =
tvs.id_type_vehicule
GROUP BY scs.nom_segment, tvs.nom_type_vehicule
ORDER BY total_revenus DESC