SELECT
    CAST(operatorname AS STRING) AS libelle_transporteur,
    CAST(operatorref AS INT64) AS transporteur_ref,
    CAST(housenumber AS STRING) AS numero_rue,
    CAST(street AS STRING) AS rue,
    CAST(addressline1 AS STRING) AS adresse_ligne_1,
    CAST(town AS STRING) AS ville,
    CAST(postcode AS STRING) AS code_postal,
    CAST(postcodeextension AS STRING) AS cp_extension,
    CAST(phone AS STRING) AS telephone,
    CAST(url AS STRING) AS url,
    CAST(furtherdetails AS STRING) AS details,
    CAST(contactperson AS STRING) AS contact,
    CAST(logo AS STRING) AS logo,
    CAST(email AS STRING) AS email
FROM {{ source('idfm_raw', 'liste_transporteurs') }}


