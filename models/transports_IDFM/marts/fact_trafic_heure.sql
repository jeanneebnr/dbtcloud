{{ config(materialized='table') }}

WITH union_horaires AS (
    SELECT * FROM {{ ref('stg_horaires_2023') }}
    UNION ALL
    SELECT * FROM {{ ref('stg_horaires_2024') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY CAST(uh.date AS DATE), CAST(uh.heure AS INT64)) AS id_trafic,
    CAST(uh.date AS DATE)AS date,
    CAST(uh.heure AS INT64)AS heure,
    CAST(uh.tranche_horaire AS STRING) AS tranche_horaire,
    CAST(dl.id_ligne AS STRING) AS id_ligne,
    CAST(uh.frequence_theorique_par_heure AS FLOAT64) AS freq_theo,
    CAST(uh.frequence_reelle_par_heure AS FLOAT64) AS freq_reel,
    CAST(uh.taux_service_pct AS FLOAT64) AS taux_service_pct,
    CAST(uh.retard_moyen_minutes AS FLOAT64) AS retard_moyen_minute,
    CAST(uh.facteur_retard AS FLOAT64) AS facteur_retard,
    CAST(uh.incident_detecte AS BOOL) AS incident_detecte,
    CAST(uh.incident_type AS STRING) AS incident_type

FROM union_horaires as uh
LEFT JOIN {{ref ('dim_lignes')}} as dl 
ON uh.id_ligne_idfm = dl.id_ligne_idfm