SELECT
    id_line AS id_ligne_idfm,
    name_line AS libelle_ligne,
    privatecode,
    id_groupoflines,
    networkname,
    valid_fromdate,
    valid_todate

FROM {{ source('idfm', 'referentiel_lignes') }}

WHERE id_line IS NOT NULL