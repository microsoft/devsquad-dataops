#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""This modules contains data manipulation rutines to work with Spark DataFrames."""

from pyspark.sql.dataframe import DataFrame
from pyspark.sql.functions import (concat_ws, col, unix_timestamp,
                                   to_date, date_format, to_timestamp,
                                   from_utc_timestamp)
from pyspark.sql import functions as f
from pyspark.sql.types import IntegerType, AtomicType
from .functions import add_hours, add_minutes, add_seconds

import logging
from typing import Dict, Union, Callable, List

logger = logging.getLogger(__name__)


def concat_columns(df: DataFrame, columnName_name: str, *columns: str, union_char: str = '_') -> DataFrame:
    """Add new column to a DataFrame. Column value is concat from
       informed list of columns

    Args:
        df (DataFrame)            : DataFrame to be updated
        columnName_name (str)     : Column name to be used to extract
                                    date value
        *columns (str)            : list of columns

    Returns:
        DataFrame: Returns new DataFrame
    """
    return df.withColumn(columnName_name, concat_ws(f'{union_char}', *columns))


def cast_columns(df: DataFrame, castType: [str, AtomicType], columns: List[str]) -> DataFrame:
    """Casts columns to a given type. `castType` can be an Spark type or a string representing
    the type.

    Parameters
    ----------
    df : DataFrame
        The `DataFrame` containing the columns
    castType : [type]
        The types to cast the columns. Types can be Spark Types or the string representing it.
    columns : List[str]
        The columns you want to cast.

    Returns
    -------
    DataFrame
        The converted `DataFrame`
    """
    for column in columns:
        df = df.withColumn(column, col(column).cast(castType))

    return df


def parse_to_unixtime_column(df: DataFrame, columnName: str,
                             dateFmt: str,
                             newColumnName: Union[str, None] = None) -> DataFrame:
    """Parses an string column to unix timestamp column in a DataFrame. If targetColumnName is not specified,
    column is overwritten

    Args:
        df (DataFrame)  : DataFrame to be updated
        columnName (str): Column name to be used to extract date value
        dateFmt (str)   : Format of Date value. Must be according to
                           Spark 3 (https://spark.apache.org/docs/3.0.0-preview2/sql-migration-guide.html)

    Returns:
        DataFrame: Returns new DataFrame
    """
    return df.withColumn(newColumnName if newColumnName else columnName,
                         unix_timestamp(col(columnName), dateFmt))


def parse_to_date_column(df: DataFrame, columnName: str, dateFmt: str, newColumnName: Union[str, None] = None) -> DataFrame:
    """Parses a date column represented in string to a `DateTime` format. String encoded format is specified
     in `dateFmt`. If targetColumnName is not specified, column is overwritten

    Args:
        df (DataFrame)  : DataFrame to be updated
        columnName (str): Column name to be used to extract date value
        dateFmt (str)   : Format of Date value. Must be according to
                           Spark 3 (https://spark.apache.org/docs/3.0.0-preview2/sql-migration-guide.html)

    Returns:
        DataFrame: Returns new DataFrame
    """

    return df.withColumn(newColumnName if newColumnName else columnName,
                         to_date(col(columnName), dateFmt))


def parse_to_time_column(df: DataFrame, columnName: str, dateTimeFmt: str, newColumnName: Union[str, None] = None) -> DataFrame:
    """Parses a time represented in string to a Time format. String encoded format is specified in
     `dateTimeFmt`. If targetColumnName is not specified, column is overwritten

    Args:
        df (DataFrame)   : DataFrame to be updated
        columnName (str) : Column name to be used to extract date value
        dateTimeFmt (str): Format of Date value. Must be according to
                           Spark 3 (https://spark.apache.org/docs/3.0.0-preview2/sql-migration-guide.html)

    Returns:
        DataFrame: Returns new DataFrame
    """
    return df.withColumn(newColumnName if newColumnName else columnName,
                         date_format(to_timestamp(col(columnName), dateTimeFmt),
                                     "HH:mm:ss"))


def parse_to_datetime_column(df: DataFrame, columnName: str, dateTimeFmt: str, newColumnName: Union[str, None] = None) -> DataFrame:
    """Parses a column to `Timestamp` format according to `dateTimeFmt`.

    Parameters
    ----------
    df : DataFrame
        DataFrame to be updated
    columnName : str
        Column name to be used to extract date/time value. If `newColumnName` is not indicated, then this column values
        will be replaced.
    dateTimeFmt : str
        Format of Date value. Must be according to Spark 3 (https://spark.apache.org/docs/latest/sql-ref-datetime-pattern.html)
    newColumnName : str, optional
        When indicated, the parsed data will be placed in this column, by default None

    Returns
    -------
    DataFrame
        The updated dataframe
    """
    return df.withColumn(newColumnName if newColumnName else columnName,
                         to_timestamp(col(columnName), dateTimeFmt))


def make_datetime_column(df: DataFrame, columnName: str, year: str, month: str, day: str,
                         hour: Union[str, None] = None, minute: Union[str, None] = None,
                         second: Union[str, None] = None, time: [str, None] = None,
                         timeFormat: str = 'HH:mm:ss') -> DataFrame:
    """Buils a new `Timestamp` column based on string columns containing each of the parts of the date. If time-related columns are indicated,
    time is constructed based on local time zone. If not, a `DateTime` column is constructed. Missing values are rounded down to the minute/hour.

    Parameters
    ----------
    df : DataFrame
        The dataframe where the data is contained
    columnName : str
        the column to build
    year : str
        Column containing the year
    month : str
        Column containing the month
    day : str
        Column containing the day
    hour : Union[str, None], optional
        Column containing the hour, by default None
    minute : Union[str, None], optional
        Column containing the minute, by default None
    second : Union[str, None], optional
        Column containing the second, by default None
    time: Union[str, None], optional
        Column containing the time part to construct the date column. This argument can't be combined with `hour`/`minute`/`second`
    timeFormat: str, optional
        When `time` is indicated, `timeFormat` represents the format where time column is stored, by default 'HH:mm:ss'
    Returns
    -------
    DataFrame
        The dataframe with the new column appended.
    """
    if timeFormat and not time:
        raise ValueError("You can't specify timeFormat if time is missing.")
    if time and (hour or minute or second):
        raise ValueError("You can't specify both time and hour/minute/second. Either use one or the others")
    if not second:
        logger.info("Seconds not specified. Minutes will be rounded down")
        second = f.lit("00")
    if not minute:
        logger.info("Minutes not specified. Hours will be rounded down")
        minute = f.lit("00")

    if not (hour or time):
        logger.info(f"Building a date column from columns '{year}', '{month}' and '{day}'")
        return parse_to_date_column(concat_columns(df, columnName, year, month, day, union_char='-'), columnName, 'yyyy-M-d')
    else:
        logger.info('Building a datetime column from columns {}'.format([year, month, day, hour, minute, second, time]))
        df = concat_columns(df, '__date_part', year, month, day, union_char='-')
        if not time:
            df = concat_columns(df, '__time_part', hour, minute, second, union_char=':')
        else:
            df = parse_to_time_column(df, time, timeFormat, '__time_part')

        df = concat_columns(df, columnName, '__date_part', '__time_part', union_char=' ')
        df = parse_to_datetime_column(df, columnName, 'yyyy-M-d HH:mm:ss', columnName)
        df = drop_columns(df, '__date_part', '__time_part')

        return df


def add_time(df: DataFrame, column: str, hours: Union[str, None] = None,
             minutes: Union[str, None] = None,
             seconds: Union[str, None] = None) -> DataFrame:
    """Adds hours, minutes or seconds to a given datatime column. `column` can be any
    timestamp column. The column indicating the time to add will be parsed to Integer.

    Parameters
    ----------
    df : DataFrame
        The source data frame
    column : str
        DateTime column
    hours : Union[str, None], optional
        Column containing the number of hours, by default None
    minutes : Union[str, None], optional
        Column containing the number of minutes, by default None
    seconds : Union[str, None], optional
        Column containing the number of seconds, by default None

    Returns
    -------
    DataFrame
        The dataframe with the column `column` with the time added.
    """
    if not (hours or minutes or seconds):
        ValueError("You have to specify at least hours, minutes or seconds")

    if hours:
        df = df.withColumn(column, add_hours(f.col(column), f.col(hours).cast(IntegerType())))
    if minutes:
        df = df.withColumn(column, add_minutes(f.col(column), f.col(minutes).cast(IntegerType())))
    if seconds:
        df = df.withColumn(column, add_seconds(f.col(column), f.col(seconds).cast(IntegerType())))

    return df


def drop_columns(df: DataFrame, *columns_to_drop: str) -> DataFrame:
    """return DataFrame without informed columns

    Parameters
    ----------
    df : DataFrame
        DataFrame to be manipulated
    *columns_to_drop : str, optional
        List of columns names to be dropped

    Returns
    -------
    DataFrame
        Returns new DataFrame
    """
    return df.drop(*columns_to_drop)


def indicate_null_or_zero(df: DataFrame, indicatorColumnName: str, columnToEvaluate: bool) -> DataFrame:
    """Adds a new column into the given DataFrame which values is `True` when the specified column
    is zero or `null`.

    Parameters
    ----------
    df : DataFrame
        The `DataFrame` to be evaluated
    indicatorColumnName : str
        The name of the new column to be added to `df`
    columnToEvaluate : str
        The column values to be evaluated for each row. Column should be numeric

    Returns
    -------
    DataFrame
        The DataFrame with an extra column named `indicatorColumnName`.

    Examples
    --------
    is_null_or_zero(df, "incidents_count", "zero_incidents")
    """
    return add_indicator_column(df,
                                indicatorColumnName,
                                ((col(columnToEvaluate) == 0) | (col(columnToEvaluate).isNull())))


def add_indicator_column(df: DataFrame, indicatorColumnName: str, expression: bool) -> DataFrame:
    """Adds a new column into the given `DataFrame` which values is `True` when the expression resolves as `True`
    for the given row, and `False` otherwise.

    Parameters
    ----------
    df : DataFrame
        The DataFrame to be evaluated
    indicatorColumnName : str
        The name of the new column to be added to `df`
    expression : bool
        The expression to be evaluated for each row

    Returns
    -------
    DataFrame
        The DataFrame with an extra column named `indicatorColumnName`.

    Examples
    --------
    add_indicator_column(df, "more_than_10", pyspark.sql.functions.col("number_of_cylinders") > 10)
    """
    return df.withColumn(indicatorColumnName, f.when(expression, True).otherwise(False))


def add_categorical_column(df: DataFrame, columnName: str, expressions: Dict[str, bool],
                           defaults: Union[str, None]) -> DataFrame:
    """Adds a new column into the given `DataFrame` which values represents a categorical variable. The category a row
    is assigned depends on the evaluation of all the expressions in the dictionary. In case of overlapping categories
    (i.e. a given row matchs multuple categories) then the last category last. Rows not matching any value will
    default to `defaults` if specified.

    Parameters
    ----------
    df : DataFrame
        The `DataFrame` to be evaluated
    columnName : str
        The name of the new column to be added to `df` with the categories
    expressions : Dict[str, bool]
        A dictionary containing all the categories to be assigned (as keys) and their corresponding rules to be
        evaluated (as values). Rules can be any expression that evaluates to `bool`.
    defaults : Union[str, None]
        The default category for not matching any of the expressions in `expressions`

    Returns
    -------
    DataFrame
        The `DataFrame` with an extra column named `columnName` of type `string`.

    Examples
    --------
    add_categorical_column(df, "engine_size", { 'small' : f.col("number_of_cylinders") < 4,
                                                'medium' : f.col("number_of_cylinders").between(4,8),
                                                'big' : f.col("number_of_cylinders") > 8 },
                                                'other')
    """
    if columnName in df.schema.names:
        logger.warning(f"Column '{columnName}' is present in the given DataFrame. Values in this column \
                     will be overwrited as a result of the operation.")

    for category, expression in expressions.items():
        if columnName in df.schema.names:
            df = df.withColumn(columnName,
                               f.when(expression, f.lit(category)).otherwise(f.col(columnName)))
        else:
            df = df.withColumn(columnName,
                               f.when(expression, f.lit(category)))

    if defaults:
        df = df.fillna({columnName: defaults})

    return df


def transform_date_time_zone(df: DataFrame, columnName: str, timeZone: str) -> DataFrame:
    """return DataFrame with specified date column transformed to specified timeZone

    Parameters
    ----------
    df : DataFrame
        DataFrame to be manipulated
    columnName:str
        The name of the column with the date to be transformed
    timeZone:str
        The timezone to transform the current dataframe column
    """
    try:
        return df.withColumn(columnName, from_utc_timestamp(col(columnName), timeZone))
    except Exception as e:
        logger.error("Exception transforming column to specified timeZone: " + e)

    return df


def drop_duplicates_rows(df: DataFrame, *criteria_columns: str) -> DataFrame:
    """return DataFrame without duplicate rows in based on certain columns or from all columns

    Parameters
    ----------
    df : DataFrame
        DataFrame to be manipulated
    *criteria_columns : str, optional
        List of columns names to remove duplicates rows

    Returns
    -------
    DataFrame
        Returns new DataFrame
    """

    if criteria_columns:
        return df.dropDuplicates(subset=[*criteria_columns])
    else:
        return df.dropDuplicates()


def replace_with_agg(df: DataFrame, column: str, replace: object, agg: Callable) -> DataFrame:
    """Replaces values in a given column by an aggregation function. If the column contains null
    or incopatible types with aggregation function, they are ignored.

    Parameters
    ----------
    df : DataFrame
        The DataFrame where `column` is in
    column : str
        The column where the values are
    replace : object
        The value you are looking to replace. It's type has to match the type of `column`
    agg : Callable
        Any aggregation function from `pyspark.sql.functions`

    Returns
    -------
    DataFrame
        The transformed DataFrame.
    """
    try:
        agg_value = df.na.drop(subset=[column]).select(agg(col(column))).first()[0]
    except Exception:
        logger.error(f'We were unable to apply the aggregation function you indicated over {column}. See error.')
        raise

    try:
        target_type = dict(df.dtypes)[column]
        logger.info(f"Target Spark type detected as '{target_type}'. Casting to '{agg_value}' to '{type(replace)}'")
        replace_by = type(replace)(agg_value)
    except Exception:
        logger.error(f'Failed to convert {agg_value} to type {type(replace)}. Mind target type should be {target_type}')
        raise

    return df.replace(replace, replace_by, column)
