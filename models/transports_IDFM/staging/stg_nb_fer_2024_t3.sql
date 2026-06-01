select 
        PARSE_DATE('%d/%m/%Y', jour) as date,
        cast(code_stif_trns as string) as id_transporteur_stif,
        cast(code_stif_res as string) as id_reseau_stif,
        cast(code_stif_arret as string) as code_stif_arret,
        cast(libelle_arret as string) as libelle_arret,
        cast(id_zdc as string) as id_zone_arret,
        cast(categorie_titre as string) as categorie_titre,
        cast(REPLACE(TRIM(CAST(nb_vald AS STRING)), ' ', '') AS INT64) AS validations_nb
from {{ source('idfm', 'nb_fer_2024_t3') }}
