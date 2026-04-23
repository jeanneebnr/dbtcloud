SELECT 
    row_number() over() as id,
    offset,
    _fivetran_synced,
    json_extract_scalar(value, '$.alert') as alert,
    json_extract_scalar(value, '$.niveau') as niveau,
    json_extract_scalar(value, '$.timestamp') as timestamp,
    json_extract_scalar(value, '$.zone') as zone
FROM {{source('fivetran', 'student_jeanne_eichelbrenner_entrepot_zone_anomalies')}}