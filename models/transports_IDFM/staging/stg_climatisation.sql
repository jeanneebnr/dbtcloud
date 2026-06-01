WITH source_data AS (
    SELECT *
    FROM {{ source('idfm', 'climatisation') }}
),

filtered AS (
    SELECT *
    FROM source_data
    WHERE climatisation != 'climatisation'
      AND id_ligne_IDFM != 'id_ligne_IDFM'
),

deduplicated AS (
    SELECT *
    FROM (
        SELECT
            *,
            row_number() OVER (
                PARTITION BY id_ligne_IDFM
                ORDER BY nom_ligne
            ) AS row_num
        FROM filtered
    )
    WHERE row_num = 1
),

clean_data AS (
    SELECT
        CAST(nom_ligne AS STRING) AS nom_ligne,
        CAST(id_ligne_IDFM AS STRING) AS id_ligne_idfm,
        CAST(climatisation AS STRING) AS climatisation
    FROM deduplicated
)

SELECT *
FROM clean_data