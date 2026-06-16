SELECT
    CAST(code_stif_trns AS STRING) AS id_transporteur_stif,
    CAST(code_stif_res AS STRING) AS id_reseau_stif,
    CAST(code_stif_ligne AS STRING) AS id_ligne_stif,
    CAST(libelle_ligne AS STRING) AS libelle_ligne,
    CAST(id_groupofligne AS STRING) AS id_groupofline,
    CAST(cat_jour AS STRING) AS categorie_jour,
    CAST(SPLIT(trnc_horr_60, 'H')[OFFSET(0)] AS STRING) AS heure,
    CAST(REPLACE(CAST(pourc_validations AS STRING), ',', '.') AS FLOAT64) AS validations_pct


FROM {{ source('idfm_raw', 'profil_surface_2023_s2') }}