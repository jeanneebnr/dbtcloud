WITH 
ft AS (
  SELECT *
  FROM {{ source('vtc', 'trajets') }}
),
d AS (
  SELECT
    id_date,
    DATE(annee, mois, jour) AS date_trajet
  FROM {{ source('vtc', 'dates') }}
)

SELECT
  ft.*,
  d.date_trajet
FROM ft
LEFT JOIN d ON ft.id_date = d.id_date