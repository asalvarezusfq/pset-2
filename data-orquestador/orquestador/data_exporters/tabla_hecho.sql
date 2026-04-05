DROP TABLE IF EXISTS clean.fact_viajes_{{ block_output("parametro", parse=lambda data, _vars: data["year"]) }}_{{ block_output("parametro", parse=lambda data, _vars: data["month"]) }};

CREATE TABLE clean.fact_viajes_{{ block_output("parametro", parse=lambda data, _vars: data["year"]) }}_{{ block_output("parametro", parse=lambda data, _vars: data["month"]) }} AS

SELECT
    --  claves
    id_vendedor,
    tipo_pago,
    id_zona_recogida,
    id_zona_dejada,

    -- timestamps
    fecha_tiempo_recogida,
    fecha_tiempo_dejada,

    --  métricas
    distancia_millas,
    monto_total,
    tarifa_base,
    propina,
    peaje,

    --  duración
    EXTRACT(EPOCH FROM (
        fecha_tiempo_dejada - fecha_tiempo_recogida
    )) / 60 AS duracion_minutos

FROM clean_stage.taxi_amarillo_{{ block_output("parametro", parse=lambda data, _vars: data["year"]) }}_{{ block_output("parametro", parse=lambda data, _vars: data["month"]) }};
