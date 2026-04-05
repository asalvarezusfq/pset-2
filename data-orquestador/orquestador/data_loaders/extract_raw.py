if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test

import pandas as pd
import requests

@data_loader
def load_data(*args, **kwargs):
    """
    Extraer el datos del dataset NYC Taxi dataset, mes por mes de un año

    Returns:
        Diccionario, datos y metadatos
    """
    year = kwargs.get('year', 2025)
    month = kwargs.get('month', 2)

    base_url = "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_{}-{:02d}.parquet"
    url = base_url.format(year, month)

    try:
        response = requests.head(url, timeout=10)
        if response.status_code != 200:
            print(f"Archivo no disponible ({response.status_code})")
            return None
    except Exception as e:
        print(f"Error verificando URL: {e}")
        return None

    print(f"Descargando: {url}")

    try:
        df = pd.read_parquet(url)
    except Exception as e:
        print(f"Error descargando {url}: {e}")
        return None 


    print(f"Filas: {df.shape[0]}")

    return df,year,month


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'
