if 'custom' not in globals():
    from mage_ai.data_preparation.decorators import custom
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test

from mage_ai.orchestration.triggers.api import trigger_pipeline
import time


@custom
def run_controller(*args, **kwargs):
    years = kwargs.get('years', [2025])
    months = kwargs.get('months', [5,6,7,8,9,10,11,12])#list(range(1, 13)))

    for year in years:
        for month in months:
            print(f"Ejecutando año {year}, mes {month}")

            trigger_pipeline(
                'raw_ingestion',
                variables={
                    'year': year,
                    'month': month
                }
            )
            time.sleep(240)  # espera para hacerlo secuencial

    return "OK"


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'