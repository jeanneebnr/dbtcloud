SELECT 
    row_number() over() as id,
    offset,
    _fivetran_synced,
    json_extract_scalar(value, '$.direction') as direction,
    json_extract_scalar(value, '$.event') as event,
    json_extract_scalar(value, '$.timestamp') as timestamp,
    json_extract_scalar(value, '$.zone') as zone
FROM {{source('fivetran', 'student_jeanne_eichelbrenner_entrepot_zone_mouvements')}}