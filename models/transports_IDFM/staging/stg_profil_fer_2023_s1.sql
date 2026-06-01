WITH source_data as (
    SELECT *
    FROM {{source('idfm', 'profil_fer_2023_s1')}}
),

deduplicated as (
        SELECT *
    FROM (
        SELECT
            *,
            row_number() OVER (
                PARTITION BY libelle_arret, cat_jour, trnc_horr_60
                ORDER BY libelle_arret
            ) as row_num
        FROM source_data
    )
    WHERE row_num = 1
),

clean_data as (
    SELECT 
        coalesce(cast(code_stif_trns as string), '9999') as id_transporteur_stif,
        coalesce(cast(code_stif_res as string), '9999') as id_reseau_stif,
        coalesce(cast(code_stif_arret as string), '9999') as id_arret_stif,
        coalesce(cast(libelle_arret as string), 'Non renseigné') as libelle_arret,
        coalesce(cast(lda as string), '99999') as id_zone_arret,
        coalesce(cast(cat_jour as string), 'Non renseigné') as categorie_jour,
        cast(SPLIT(trnc_horr_60, 'H')[OFFSET(0)] as string) as heure,
        cast(REPLACE(CAST(pourc_validations AS STRING), ',', '.') as float64) as validations_pct
    FROM deduplicated
)

SELECT *
FROM clean_data