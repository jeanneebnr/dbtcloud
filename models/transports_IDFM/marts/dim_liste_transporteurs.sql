{{ config(materialized='table') }}

SELECT
    ROW_NUMBER() OVER (ORDER BY transporteur_ref) AS id_operateur,
    libelle_transporteur AS libelle_transporteur,
    transporteur_ref AS transporteur_ref,
    numero_rue AS numero_rue,
    rue AS rue,
    adresse_ligne_1 AS adresse_ligne_1,
    ville AS ville,
    code_postal AS code_postal,
    cp_extension AS code_postal_extension,
    telephone AS telephone,
    url AS url,
    details AS details,
    contact AS contact,
    logo AS logo,
    email AS email
FROM stg_liste_transporteurs