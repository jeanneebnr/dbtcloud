WITH source_data AS (
    SELECT *
    FROM {{ source('idfm_raw', 'climatisation') }}
),


deduplicated AS (
    SELECT *
    FROM (
        SELECT
            *,
            row_number() OVER (
                PARTITION BY lineid
                ORDER BY linename
            ) AS row_num
        FROM source_data
    )
    WHERE row_num = 1
),

clean_data AS (
    SELECT
        cast(lineid AS string) AS id_ligne_idfm,
        replace(replace(split(cast(extensions AS string), ':')[OFFSET(7)],'"',''), '}}','') AS climatisation
    FROM deduplicated
)

SELECT *
FROM clean_data