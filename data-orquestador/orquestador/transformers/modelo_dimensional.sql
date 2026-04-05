-- crear schema
CREATE SCHEMA IF NOT EXISTS clean;

-- **** Dimension Vendedor ****
DROP TABLE IF EXISTS clean.dim_vendor;

CREATE TABLE clean.dim_vendor AS
SELECT DISTINCT
    id_vendedor,

    CASE id_vendedor
        WHEN 1 THEN 'Creative Mobile Technologies'
        WHEN 2 THEN 'Curb Mobility'
        WHEN 6 THEN 'Myle Technologies Inc'
        WHEN 7 THEN 'Helix'
        ELSE 'Desconocido'
    END AS nombre_vendedor

FROM clean_stage.taxi_amarillo_{{ block_output("obtener_parametros", parse=lambda data, _vars: data["year"]) }}_{{ block_output("obtener_parametros", parse=lambda data, _vars: data["month"]) }};

-- **** Tipo de pago ****
DROP TABLE IF EXISTS clean.dim_payment_type;

CREATE TABLE clean.dim_payment_type AS
SELECT DISTINCT
    tipo_pago,

    CASE tipo_pago
        WHEN 0 THEN 'Flex Fare trip'
        WHEN 1 THEN 'Tarjeta crédito'
        WHEN 2 THEN 'Efectivo'
        WHEN 3 THEN 'Sin cargo'
        WHEN 4 THEN 'Disputa'
        WHEN 5 THEN 'Desconocido'
        WHEN 6 THEN 'Viaje anulado'
        ELSE 'Otro'
    END AS descripcion_pago

FROM clean_stage.taxi_amarillo_{{ block_output("obtener_parametros", parse=lambda data, _vars: data["year"]) }}_{{ block_output("obtener_parametros", parse=lambda data, _vars: data["month"]) }};


-- **** Ubicacion Inicio del viaje ****
DROP TABLE IF EXISTS clean.dim_pickup_location;

CREATE TABLE clean.dim_pickup_location AS
SELECT DISTINCT
    t.id_zona_recogida,

    z."borough"      AS borough,
    z."zone"         AS zona,
    z."service_zone" AS tipo_servicio

FROM clean_stage.taxi_amarillo_{{ block_output("obtener_parametros", parse=lambda data, _vars: data["year"]) }}_{{ block_output("obtener_parametros", parse=lambda data, _vars: data["month"]) }} t
LEFT JOIN clean_stage.code_location z
    ON t.id_zona_recogida = z."locationid";


-- **** Ubicacion Fin del viaje ****
DROP TABLE IF EXISTS clean.dim_dropoff_location;

CREATE TABLE clean.dim_dropoff_location AS
SELECT DISTINCT
    t.id_zona_dejada,

    z."borough"      AS borough,
    z."zone"         AS zona,
    z."service_zone" AS tipo_servicio

FROM clean_stage.taxi_amarillo_{{ block_output("obtener_parametros", parse=lambda data, _vars: data["year"]) }}_{{ block_output("obtener_parametros", parse=lambda data, _vars: data["month"]) }} t
LEFT JOIN clean_stage.code_location z
    ON t.id_zona_dejada = z."locationid";

