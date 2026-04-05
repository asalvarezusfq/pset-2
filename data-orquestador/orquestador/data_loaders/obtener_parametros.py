if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@data_loader
def load_data(*args, **kwargs):
    """
    Template code for loading data from any source.

    Returns:
        Anything (e.g. data frame, dictionary, array, int, str, etc.)
    """
    # Specify your data loading logic here

    import pandas as pd
    from sqlalchemy import create_engine, text
    from mage_ai.data_preparation.shared.secrets import get_secret_value

    USER = get_secret_value('user_db')
    PASS = get_secret_value('password_db')
    HOST = get_secret_value('host_db')
    PORT = get_secret_value('port_db')
    DB   = get_secret_value('name_db')


    engine = create_engine(f'postgresql://{USER}:{PASS}@{HOST}:{PORT}/{DB}')
    url = "https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv"
    df_zones = pd.read_csv(url)
        
    # nombres de columnas sigan el estándar SQL (minúsculas)
    df_zones.columns = [c.lower() for c in df_zones.columns]
    # Cargar a PostgreSQL
    print("Cargando a PostgreSQL en clean_stage.code_location...")
    df_zones.to_sql(
        name='code_location', 
        con=engine, 
        schema='clean_stage', 
        if_exists='replace', 
        index=False,
        method='multi'
        )
        
    print("¡Carga completada con éxito!")


    year = kwargs.get("year", 2025)
    month = kwargs.get("month", 1)

    return [dict(year = str(year),month= f"{int(month):02d}")]


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'
