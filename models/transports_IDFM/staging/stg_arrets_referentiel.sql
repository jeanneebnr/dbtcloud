SELECT
    CAST(zdaid AS STRING) AS id_arret_idfm,
    CAST(zdcid AS STRING) AS id_zdc,
    zdaname               AS libelle_arret,
    zdatown               AS ville,
    zdapostalregion       AS code_postal,
    zdatype               AS type_transport

FROM {{ source('idfm', 'referentiel_arrets') }}

WHERE zdaid IS NOT NULL