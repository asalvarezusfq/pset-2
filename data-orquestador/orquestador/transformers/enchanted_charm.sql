SELECT *
FROM raw_data.taxi_amarillo_{{ block_output("parametros", parse=lambda data, _vars: data["year"]) }}_{{ block_output("parametros", parse=lambda data, _vars: data["month"]) }}
LIMIT 1000
