{% test freshness_by_max_date(model, threshold_days) %}
-- Vérifie si les données du modèle sont trop anciennes
WITH m AS (
  SELECT MAX(date_trajet) AS derniere_date
  FROM {{ model }}
)
SELECT *
FROM m
WHERE DATE_DIFF(CURRENT_DATE(), derniere_date, DAY) > {{ threshold_days }}
{% endtest %}