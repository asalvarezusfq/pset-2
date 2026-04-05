if 'custom' not in globals():
    from mage_ai.data_preparation.decorators import custom
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test

from mage_ai.orchestration.triggers.api import trigger_pipeline
import time


@custom
def run_controller(*args, **kwargs):
    years = kwargs.get('years', [2025])
    months = kwargs.get('months', [1,2,3,4,5,6,7,8,9,10,11,12]) #list[range(1,13)]

    # RAW → CLEAN → FACT
    for year in years:
        for month in months:
            print(f"\n🔹 Ejecutando año {year}, mes {month}")

            # --- RAW ---
            trigger_pipeline(
                'raw_ingestion',
                variables={
                    'year': year,
                    'month': month
                }
            )
            time.sleep(240)

            # --- CLEAN ---
            trigger_pipeline(
                'clean_transformation',
                variables={
                    'year': year,
                    'month': month
                }
            )
            time.sleep(90)

            # --- FACT ---
            trigger_pipeline(
                'fact_table',
                variables={
                    'year': year,
                    'month': month
                }
            )
            time.sleep(90)

    # DIMENSIONES
    trigger_pipeline(
        'modelo_dimensional'
    )
    return "OK"


@test
def test_output(output, *args) -> None:
    assert output is not None, 'The output is undefined'