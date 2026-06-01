{{ config(materialized='table') }}

SELECT
    ROW_NUMBER() OVER (ORDER BY operatorref) AS id_operateur,
    operatorname                             AS libelle_transporteur,
    operatorref                              AS transporteur_ref,
    housenumber                              AS num_rue,
    street                                  AS rue,
    addressline1                             AS adresse_ligne_1,
    town                                     AS ville,
    postcode                                 AS code_postal,
    postcodeextension                        AS code_postal_extension,
    phone                                    AS tel,
    url,
    furtherdetails                           AS detail,
    contactperson                            AS contact,
    logo,
    email

FROM {{ source('idfm', 'liste_transporteurs') }}