WITH source_data AS (
    SELECT *
    FROM {{ source('idfm', 'nb_surface_2023_t4') }}
), 

deduplicated AS (
    SELECT * 
    FROM (
        SELECT
            *,
            row_number() OVER (
                PARTITION BY jour, code_stif_ligne, categorie_titre
                ORDER BY libelle_ligne
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
        CAST(code_stif_ligne AS string) AS id_ligne_stif,
        CAST(libelle_ligne AS string) AS libelle_ligne, 
        CAST(id_groupoflines AS string) AS id_groupoflines, 
        CAST(categorie_titre AS string) AS categorie_titre,
        SAFE_CAST(nb_vald AS INT64) AS validations_nb 
    FROM deduplicated
)

SELECT *
FROM clean_data