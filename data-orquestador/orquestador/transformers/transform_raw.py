if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test

import pandas as pd

@transformer
def transform(data,*args, **kwargs):
    """
    Transformacion: Renombrado consistente de columnas

    """
    if data is None:
        return None

    df, year, month = data

    df.columns = [col.lower() for col in df.columns]#minusculas
    new_columns = {
        "vendorid": "vendor_id",
        "ratecodeid": "ratecode_id",
        "pulocationid": "pu_location_id",
        "dolocationid": "do_location_id"
    } #estandarizar nombres - snake
    df = df.rename(columns=new_columns)    

    # booleano
    if 'store_and_fwd_flag' in df.columns:
        df['store_and_fwd_flag'] = df['store_and_fwd_flag'].map({
            'Y': True,
            'N': False
        })

    # numéricos
    for col in ['congestion_surcharge', 'airport_fee']:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors='coerce')


    print(f"Transformación aplicada para {year}-{month:02d}")

    return df,year,month


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'
