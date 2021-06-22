#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
This script allows users to validate the quality of the datasets.
"""

from pyspark.sql.dataframe import DataFrame
from pyspark.sql.functions import to_date
from typing import List


def has_null(df: DataFrame, cols: List[str]) -> bool:
    """Validates whether or not the DataFrame columns in the list have NULL values.

    Parameters
    ----------
    df : DataFrame
        The DataFrame where the validation will occur.
    cols : list
        A list of strings with the name of the columns to be validaded.

    Returns
    -------
    bool
        Returns a boolean indicating whether or not the columns have NULL values.
    """
    return any([df.filter(df[col].isNull()).count() for col in cols])


def has_invalid_dates(df: DataFrame, cols: List[str], format: str) -> bool:
    """Validates whether or not the DataFrame columns in the list have invalid dates.

    Parameters
    ----------
    df : DataFrame
        The DataFrame where the validation will occur.
    cols : list
        A list of strings with the name of the columns to be validaded.
    format: str
        The date/time format to be used.

    Returns
    -------
    bool
        Returns a boolean indicating whether or not the columns have invalid dates.
    """
    return any([df.filter(to_date(df[col], format).isNull()).count() for col in cols])


def has_inconsistent_dates(df: DataFrame, dateColumn1: str, dateColumn2: str, format: str, operator: classmethod) -> bool:
    """Validates whether or not the DataFrame has dateColumn1 and dateColumn2 inconsistent based on the operator
    used for the comparison.

    Parameters
    ----------
    df : DataFrame
        The DataFrame where the validation will occur.
    dateColumn1: str
        The date column used in the left side of the operator function.
    dateColumn2: str
        The date column used in the right side of the operator function.
    format: str
        The date/time format to be used.
    operator: classmethod
        The operator function to be used for the comparison, such as:
            operator.lt
            operator.le
            operator.eq
            operator.ne
            operator.ge
            operator.gt

    Returns
    -------
    bool
        Returns a boolean indicating whether or not the DataFrame has dateColumn1 and dateColumn2 inconsistent.
    """
    return df.filter(operator(to_date(df[dateColumn1], format), to_date(df[dateColumn2], format))).count() > 0
