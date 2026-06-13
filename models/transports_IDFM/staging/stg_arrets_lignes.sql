WITH source_data AS (
    SELECT * 
    FROM {{ source('idfm_raw', 'arrets_lignes') }}
),

deduplicated AS (
    SELECT *
    FROM (
        SELECT
            *,
            row_number() OVER (
                PARTITION BY id, stop_id
                ORDER BY id
            ) AS row_num
        FROM source_data
    )
    WHERE row_num = 1
),

clean_data AS (
    SELECT 
        split(cast(id AS string), ':')[OFFSET(1)] AS id_ligne_idfm,
        cast(route_long_name AS string) AS libelle_ligne_long,
        cast(shortname AS string) AS libelle_ligne_court,        
        split(replace(cast(stop_id AS string), 'monomodalStopPlace:', ''), ':')[OFFSET(1)] AS id_stop_idfm,
        cast(stop_name AS string) AS libelle_arret,
        cast(stop_lon AS float64) AS longitude,
        cast(stop_lat AS float64) AS latitude,
        cast(operatorname AS string) AS libelle_transporteur,
        coalesce(cast(bookingrules AS string), 'pas de reservation') AS reservation,
        cast(mode AS string) AS type_transport,
        cast(nom_commune AS string) AS ville,
        cast(code_insee AS string) AS code_postal
    FROM deduplicated
)


SELECT * 
FROM clean_data