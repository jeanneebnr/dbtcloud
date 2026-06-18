WITH source_data AS (
    SELECT *
    FROM {{source('idfm_raw','nb_fer_2023_s1')}}
), 

deduplicated AS (
    SELECT * 
    FROM (
        SELECT
            *,
            row_number() OVER (
                PARTITION BY jour, code_stif_arret
                ORDER BY libelle_arret
            ) AS row_num
        FROM source_data
    )
    WHERE row_num = 1 
), 

clean_data AS (
    SELECT 
        PARSE_DATE('%d/%m/%Y', jour) AS date,
        CAST(code_stif_trns AS string) AS id_transporteur_stif,
        CAST(code_stif_res AS string) AS id_reseau_stif,
        CAST(code_stif_arret as string) as id_stif_arret,
        CAST(libelle_arret as string) as libelle_arret,
        CAST(lda as string) as id_zone_arret,
        CAST(categorie_titre AS string) AS categorie_titre,
        SAFE_CAST(REPLACE(TRIM(CAST(nb_vald AS STRING)), ' ', '') AS INT64) AS validations_nb
    FROM deduplicated
)

SELECT *
FROM clean_data