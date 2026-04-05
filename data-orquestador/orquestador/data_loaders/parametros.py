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
    year = kwargs.get("year", 2025)
    month = kwargs.get("month", 2)

    return [dict(year = str(year),month= f"{int(month):02d}")]
    #data = {
    #    "year": kwargs.get("year", 2025),
    #    "month": kwargs.get("month", 1)#list(range(1, 13)))
    #}

    #return data


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'
