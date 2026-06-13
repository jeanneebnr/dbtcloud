WITH source_data AS (
    SELECT *
    FROM {{ source('idfm_raw', 'accessibilite_en_gare') }}
),

deduplicated AS (
    SELECT *
    FROM (
        SELECT
            *,
            row_number() OVER (
                PARTITION BY stop_point_id
            ) AS row_num
        FROM source_data
    )
    WHERE row_num = 1
),

clean_data AS (
    SELECT
        cast(split(stop_point_id, ':')[OFFSET(3)] AS int64) AS id_stop_idfm,
        cast(stop_name AS string) AS libelle_arret,
        coalesce(cast(accessibility_level_name as string), 'non renseigné') as niveau_accessibilite,
        coalesce(cast(accessibility_level_id as string), 'non renseigné') as nom_accessibilite,
        cast(split(stop_point_geopoint, '; ')[OFFSET(0)] AS float64) AS latitude,
        cast(split(stop_point_geopoint, '; ')[OFFSET(1)] AS float64) AS longitude
    FROM deduplicated
)

SELECT *
FROM clean_data