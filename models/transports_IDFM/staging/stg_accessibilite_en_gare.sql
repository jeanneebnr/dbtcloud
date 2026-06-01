WITH source_data AS (
    SELECT *
    FROM {{ source('idfm', 'accessibilite_en_gare') }}
),

deduplicated AS (
    SELECT *
    FROM (
        SELECT
            *,
            row_number() OVER (
                PARTITION BY id_stop_point
            ) AS row_num
        FROM source_data
    )
    WHERE row_num = 1
),

clean_data AS (
    SELECT
        cast(id_stop_point AS string) AS id_stop_idfm,
        cast(stop_name AS string)     AS libelle_arret,
        coalesce(cast(accessibility_level_name as string), 'non renseigné') as niveau_accessibilite,
        coalesce(cast(accessibility_level_id as string), 'non renseigné') as note_accessibilite,
        cast(lat AS float64) AS latitude,
        cast(lon AS float64) AS longitude
    FROM deduplicated
)

SELECT *
FROM clean_data