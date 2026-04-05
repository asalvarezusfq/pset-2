-- crear schema
CREATE SCHEMA IF NOT EXISTS clean_stage;

-- eliminar tabla si existe
DROP TABLE IF EXISTS clean_stage.taxi_amarillo_{{ block_output("parametros", parse=lambda data, _vars: data["year"]) }}_{{ block_output("parametros", parse=lambda data, _vars: data["month"]) }};

CREATE TABLE clean_stage.taxi_amarillo_{{ block_output("parametros", parse=lambda data, _vars: data["year"]) }}_{{ block_output("parametros", parse=lambda data, _vars: data["month"]) }} AS

WITH base AS (
    SELECT *
    FROM raw_data.taxi_amarillo_{{ block_output("parametros", parse=lambda data, _vars: data["year"]) }}_{{ block_output("parametros", parse=lambda data, _vars: data["month"]) }}
),

-- eliminar duplicados logicos
deduplicados AS (
    SELECT DISTINCT ON (
        vendor_id,
        tpep_pickup_datetime,
        tpep_dropoff_datetime,
        do_location_id,
        total_amount
    ) *
    FROM base
),

-- eliminar viajes cancelados
sin_cancelados AS (
    SELECT *
    FROM deduplicados
    WHERE NOT (
        (fare_amount = 0 OR trip_distance = 0)
        AND pu_location_id = do_location_id
    )
),

-- manejo de passenger_count
pasajeros AS (
    SELECT *,
        CASE 
            WHEN passenger_count IS NULL AND payment_type = 0 THEN -1
            WHEN passenger_count IS NULL THEN NULL
            ELSE passenger_count
        END AS numero_pasajeros_fix
    FROM sin_cancelados
),

-- rate_code_id null → 99
rate_code AS (
    SELECT *,
        COALESCE(ratecode_id, 99) AS ratecode_id_fix
    FROM pasajeros
),

-- valores negativos → positivos
montos AS (
    SELECT *,
        ABS(fare_amount) AS fare_amount_fix,
        ABS(extra) AS extra_fix,
        ABS(mta_tax) AS mta_tax_fix,
        ABS(tip_amount) AS tip_amount_fix,
        ABS(tolls_amount) AS tolls_amount_fix,
        ABS(improvement_surcharge) AS improvement_surcharge_fix,
        ABS(total_amount) AS total_amount_fix,
        ABS(congestion_surcharge) AS congestion_surcharge_fix,
        ABS(airport_fee) AS airport_fee_fix,
        ABS(cbd_congestion_fee) AS cbd_congestion_fee_fix
    FROM rate_code
),

-- filtros de tarifas
filtrado AS (
    SELECT *
    FROM montos
    WHERE
        -- eliminar pasajeros nulos
        numero_pasajeros_fix IS NOT NULL

        -- mta_tax diferente de 0.5 o 0
        AND mta_tax_fix IN (0, 0.5)

        -- tip_amount, pero que payment_type = 2 (efectivo )
        AND NOT (tip_amount_fix > 0 AND payment_type = 2)

        -- improvement_surcharge sea diferente de $1 o 0
        AND improvement_surcharge_fix IN (0, 1)

        -- congestion_surcharge sea diferente de $2.5 o 0
        AND congestion_surcharge_fix IN (0, 2.5)

        -- airport_fee sea diferente de $1.75 o 0
        AND airport_fee_fix IN (0, 1.75)

        -- cbd_congestion_fee sea diferente de $0.75 o 0
        AND cbd_congestion_fee_fix IN (0, 0.75)
)

-- selección final con nombres en español
SELECT
    vendor_id                              AS id_vendedor,
    tpep_pickup_datetime                  AS fecha_tiempo_recogida,
    tpep_dropoff_datetime                 AS fecha_tiempo_dejada,

    numero_pasajeros_fix                  AS numero_pasajeros,
    trip_distance                         AS distancia_millas,

    fare_amount_fix                       AS tarifa_base,
    tip_amount_fix                        AS propina,
    tolls_amount_fix                      AS peaje,
    total_amount_fix                      AS monto_total,

    ratecode_id_fix                       AS codigo_tarifa,
    payment_type                          AS tipo_pago,

    pu_location_id                        AS id_zona_recogida,
    do_location_id                        AS id_zona_dejada,

    extra_fix                             AS extra,
    mta_tax_fix                           AS impuesto_mta,
    improvement_surcharge_fix             AS recargo_mejora,
    congestion_surcharge_fix              AS recargo_congestion,
    airport_fee_fix                       AS tarifa_aeropuerto,
    cbd_congestion_fee_fix                AS recargo_cbd

FROM filtrado;