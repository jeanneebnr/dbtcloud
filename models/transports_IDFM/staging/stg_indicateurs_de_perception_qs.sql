SELECT
    operateur        AS transporteur_name,
    dsp,
    mode             AS type_transport,
    groupe_de_lignes AS libelle_groupe_de_lignes,
    id_ligne_IDFM    AS id_ligne_idfm,
    ligne            AS libelle_ligne,
    annee,
    resultat
FROM {{ source('idfm', 'indicateurs_de_perception_qs') }}