WITH source_data AS (
    SELECT *
    FROM {{ source('idfm_raw', 'horaires_2024') }}
),


deduplicated AS (
    SELECT *
    FROM (
        SELECT
            *,
            row_number() OVER (
                PARTITION BY date, heure, ligne_id
                ORDER BY ligne_nom
            ) AS row_num
        FROM source_data
    )
    WHERE row_num = 1
),

clean_data as (
SELECT
    cast(date as date) as date,
    cast(annee as int64) as annee,
    cast(mois as int64) as mois,
    cast(jour as int64) as jour,
    cast(jour_semaine as string) as jour_semaine,
    cast(heure as int64) as heure,
    cast(tranche_horaire as string) as heure_pointe,
    split(cast(ligne_id as string), ':')[OFFSET(1)] as id_ligne_idfm,
    cast(ligne_nom as string) as libelle_ligne,
    cast(type_transport as string) as type_transport,
    cast(frequence_theorique_par_heure as float64) as frequence_theorique,
    cast(frequence_reelle_par_heure as float64) as frequence_reelle,
    cast(taux_service_pct as float64) as taux_service_pct,
    cast(retard_moyen_minutes as float64) as retard_moyen_minutes,
    cast(facteur_retard as float64) as facteur_retard,
    cast(incident_detecte as bool) as incident_detected,
    cast(incident_type as string) as incident_type,
    cast(temperature as float64) as temperature,
    cast(precipitation as float64) as preceipitation,
    cast(neige as float64) as neige,
    cast(vent as float64) as vent,
    cast(meteo_defavorable as bool) as meteo_defavorable
FROM deduplicated
)

SELECT *
FROM clean_data