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
  f.vent_vitesse_kmh,
  f.vent_direction,
  f.vent_direction_cardinale,
  f.vent_rafale,
  f.nuages,
  f.visibilite,
  f.visibilite_km,
  f.probabilite_pluie,
  f.indice_mobilite,
  f.score_temperature,
  f.score_pluie,
  f.score_vent,
  f.score_visibilite,
  f.score_nuages,
  f.categorie_mobilite

FROM {{ ref('stg_forecast') }} f

LEFT JOIN {{ ref('dim_ville') }} v
  ON f.ville = v.ville AND f.pays = v.pays

LEFT JOIN {{ ref('dim_condition') }} c
  ON f.condition = c.condition
  AND f.description = c.description

LEFT JOIN {{ ref('dim_temps') }} t
  ON f.timestamp_prevision = t.timestamp