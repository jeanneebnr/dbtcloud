{{ config(materialized='table') }}

SELECT
  f.timestamp_prevision,
  f.timestamp_insertion,
  v.ville_id,
  c.condition_id,
  t.temps_id,
  f.temperature,
  f.temp_min,
  f.temp_max,
  f.amplitude_thermique,
  f.feels_like,
  f.humidite,
  f.pression,
  f.pression_mer,
  f.pression_sol,
  f.vent_vitesse,
  f.vent_direction,
  f.vent_direction_cardinale,
  f.vent_rafale,
  f.nuages,
  f.visibilite,
  f.probabilite_pluie

FROM {{ ref('stg_forecast') }} f

LEFT JOIN {{ ref('dim_ville') }} v
  ON f.ville = v.ville

LEFT JOIN {{ ref('dim_condition') }} c
  ON f.condition = c.condition
  AND f.description = c.description

LEFT JOIN {{ ref('dim_temps') }} t
  ON f.timestamp_prevision = t.timestamp