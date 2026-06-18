SELECT
    cast(zdaid AS string) AS id_arret_idfm,
    cast(zdcid AS string) AS id_zdc,
    cast(zdaname AS string) AS libelle_arret,
    cast(zdatown AS string) AS ville,
    cast(zdapostalregion AS string) AS code_postal,
    cast(zdatype AS string) AS type_transport
FROM {{ source('idfm_reference', 'referentiel_arrets') }}
WHERE zdaid IS NOT NULL