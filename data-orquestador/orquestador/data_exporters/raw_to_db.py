from mage_ai.settings.repo import get_repo_path
from mage_ai.io.config import ConfigFileLoader
from mage_ai.io.postgres import Postgres
from os import path
import math

if 'data_exporter' not in globals():
    from mage_ai.data_preparation.decorators import data_exporter


@data_exporter
def export_data_to_postgres(data, **kwargs) -> None:
    """
    Export data in chunks to PostgreSQL (robust for large datasets).
    """

    if data is None:
        print("No hay datos para exportar")
        return

    df, year, month = data

    schema_name = 'raw_data'
    table_name = f"taxi_amarillo_{year}_{month:02d}"

    config_path = path.join(get_repo_path(), 'io_config.yaml')
    config_profile = 'default'

    chunk_size = 200000

    total_rows = df.shape[0]
    num_chunks = math.ceil(total_rows / chunk_size)

    print(f"Total filas: {total_rows}")
    print(f"Número de chunks: {num_chunks}")
    print(f"Tabla destino: {schema_name}.{table_name}")

    with Postgres.with_config(ConfigFileLoader(config_path, config_profile)) as loader:

        for i in range(num_chunks):

            start = i * chunk_size
            end = min((i + 1) * chunk_size, total_rows)

            chunk_df = df.iloc[start:end]

            if i == 0:
                loader.export(
                    chunk_df,
                    schema_name,
                    table_name,
                    index=False,
                    if_exists='replace'
                )
            else:
                loader.export(
                    chunk_df,
                    schema_name,
                    table_name,
                    index=False,
                    if_exists='append'
                )

    print(f"Datos cargados correctamente en {schema_name}.{table_name}")

    # liberar memoria
    del df