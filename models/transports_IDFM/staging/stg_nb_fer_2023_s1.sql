SELECT
    PARSE_DATE('%d/%m/%Y', jour) as date,
    cast(code_stif_trns as string) as id_transporteur_stif,
    cast(code_stif_res as string) as id_reseau_stif,
    cast(code_stif_arret as string) as code_stif_arret,
    cast(libelle_arret as string) as libelle_arret,
    cast(lda as string) as id_zone_arret,
    cast(categorie_titre as string) as categorie_titre,
    cast(nb_vald as int64) as validations_nb
from {{ source('idfm', 'nb_fer_2023_s1') }}



