SELECT
    CAST(code_stif_trns AS STRING)                                         AS id_transporteur_stif,
    code_stif_res                                                          AS id_reseau_stif,
    code_stif_ligne                                                        AS id_ligne_stif,
    libelle_ligne,
    id_groupofligne,
    cat_jour                                                               AS categorie_jour,
    CAST(SPLIT(trnc_horr_60, 'H')[OFFSET(0)] AS STRING)                   AS heure,
    CAST(REPLACE(CAST(pourc_validations AS STRING), ',', '.') AS FLOAT64) AS validations_pct

FROM {{ source('idfm', 'profil_surface_2023_s1') }}