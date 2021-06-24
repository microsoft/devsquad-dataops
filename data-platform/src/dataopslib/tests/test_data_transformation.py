#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Tests for `dataopslib.data_transformation` module."""

import pytest
from pyspark.sql.types import StringType

try:
    import dataopslib.spark.data_transformation as transformation
    import dataopslib.schemas as schemas

    # Spark specifics
    import pyspark.sql.functions as f
    from pyspark.sql.types import FloatType
except ImportError:
    import os
    import sys
    cur_dir = os.path.dirname(__file__)
    # Add the parent directory in the search for modules when importing
    sys.path.append(os.path.abspath(os.path.join(cur_dir, os.pardir)))
    import dataopslib.spark.data_transformation as transformation
    import dataopslib.schemas as schemas


@pytest.fixture
def spark():
    """Spark Session fixture
    """
    from pyspark.sql import SparkSession

    spark = SparkSession.builder\
        .master("local")\
        .appName("Unit Testing")\
        .getOrCreate()
    spark.sparkContext.setLogLevel("ERROR")
    return spark


def transform_data_test(spark):
    schema = schemas.get_schema("sample_schema")
    df = spark.read.csv("./data/sample_data.csv", header=True, schema=schema)
    assert transformation.transform_data(df) is True


def test_has_added_column(spark):
    schema = schemas.get_schema("AirportCodeSchema")
    df = spark.read.csv("./data/AirportCodeLocationLookupClean.csv", header=True, schema=schema)
    newDF = transformation.concat_columns(df, "newColumn", "AIRPORT", "DISPLAY_AIRPORT_NAME")
    assert "newColumn" in newDF.schema.names


def test_has_droped_column(spark):
    schema = schemas.get_schema("sample_schema")
    df = spark.read.csv("./data/sample_data.csv", header=True, schema=schema)
    newDF = transformation.drop_columns(df, "START_DATE")
    assert "START_DATE" not in newDF.schema.names


def test_has_parsed_time_column_dt(spark):
    schema = schemas.get_schema("sample_schema")
    df = spark.read.csv("./data/sample_data.csv", header=True, schema=schema)
    newColumnName = "START_DATE_time_agg"
    newDF = transformation.parse_to_time_column(df, "START_DATE", "MM/dd/yyyy HH:mm:ss", newColumnName)
    assert newColumnName in newDF.schema.names


def test_has_parsed_unixtime_column(spark):
    schema = schemas.get_schema("sample_schema")
    df = spark.read.csv("./data/sample_data.csv", header=True, schema=schema)
    newColumnName = "END_DATE_unixtime"
    newDF = transformation.parse_to_unixtime_column(df, "END_DATE", "MM/dd/yyyy HH:mm:ss", newColumnName)
    assert newColumnName in newDF.schema.names


def test_has_parsed_date_column(spark):
    schema = schemas.get_schema("sample_schema")
    df = spark.read.csv("./data/sample_data.csv", header=True, schema=schema)
    newColumnName = "START_DATE_date_agg"
    newDF = transformation.parse_to_date_column(df, "START_DATE", "MM/dd/yyyy HH:mm:ss", newColumnName)
    assert newColumnName in newDF.schema.names


def test_parsed_datetime_column(spark):
    originalValue = [(10, '2019-12-21 09:15:32')]
    df = spark.createDataFrame(originalValue, ['DELAY', 'START_DATE'])
    newDF = transformation.parse_to_datetime_column(df, 'START_DATE', 'yyyy-MM-dd HH:mm:ss')

    assert newDF.filter(newDF['START_DATE'].isNull()).count() == 0


def test_transform_date_time_zone(spark):
    originalValue = [(1, '2019-12-21 09:15:32')]
    expectedValue = [(1, '2019-12-21 06:15:32')]
    df = spark.createDataFrame(originalValue, ['ID', 'START_DATE'])
    newDF = transformation.transform_date_time_zone(df, "START_DATE", "America/Sao_Paulo")
    expected = spark.createDataFrame(expectedValue, ['ID', 'START_DATE'])
    output_df = newDF.withColumn("START_DATE", newDF["START_DATE"].cast(StringType()))
    assert output_df.select('START_DATE').collect()[0] == expected.select('START_DATE').collect()[0]


def test_has_droped_duplicates_rows(spark):
    originalValue = [(1, 'a'), (1, 'a')]
    expectedValue = [(1, 'a')]
    df = spark.createDataFrame(originalValue, ["ID", "VALUE"])
    newDF = transformation.drop_duplicates_rows(df, "ID")
    expected = spark.createDataFrame(expectedValue, ["ID", "VALUE"])
    assert newDF.select('VALUE').collect()[0] == expected.select('VALUE').collect()[0]


def test_has_added_indicator_column(spark):
    new_column_name = "starts_with_yes"
    df = spark.createDataFrame(["yes123", "no123", "123yes", """123no["yes"]"""], "string").toDF("location")
    newDF = transformation.add_indicator_column(df, new_column_name, f.col("location").startswith("yes"))

    assert new_column_name in newDF.schema.names


def test_correct_assignment_indicator_column(spark):
    new_column_name = "starts_with_yes"
    df = spark.createDataFrame(["yes123", "no123", "123yes", """123no["yes"]"""], "string").toDF("location")
    newDF = transformation.add_indicator_column(df, new_column_name, f.col("location").startswith("yes"))

    indicators = dict(newDF.groupBy(new_column_name).count().collect())
    assert indicators[True] == 1 and indicators[False] == 3


def test_has_added_categorical_column(spark):
    new_column_name = "engine_size"
    df = spark.createDataFrame([3.0, 2.0, 12.0, 2.0, 5.0], FloatType()).toDF("number_of_cylinders")
    newDF = transformation.add_categorical_column(df,
                                                  "engine_size",
                                                  {
                                                    'small': f.col("number_of_cylinders") < 4.0,
                                                    'medium': f.col("number_of_cylinders").between(4.0, 8.0),
                                                    'big': f.col("number_of_cylinders") > 8.0
                                                  },
                                                  'other')
    assert new_column_name in newDF.schema.names


def test_correct_assignment_categorical_column(spark):
    new_column_name = "engine_size"
    df = spark.createDataFrame([3.0, 2.0, 12.0, 2.0, 5.0], FloatType()).toDF("number_of_cylinders")
    newDF = transformation.add_categorical_column(df,
                                                  "engine_size",
                                                  {
                                                    'small': f.col("number_of_cylinders") < 4.0,
                                                    'medium': f.col("number_of_cylinders").between(4.0, 8.0),
                                                    'big': f.col("number_of_cylinders") > 8.0
                                                  },
                                                  'other')
    counts = dict(newDF.groupBy(new_column_name).count().collect())
    expected = {'medium': 1, 'small': 3, 'big': 1}
    assert counts == expected


def test_datetime_column_added(spark):
    df = spark.read.csv("./data/FlightDelaysWithAirportCodes.csv", header=True)
    new_df = transformation.make_datetime_column(df, 'departure_time', 'Year', 'Month', 'DayofMonth',
                                                 time='CRSDepTime', timeFormat='Hmm')
    assert "departure_time" in new_df.schema.names
    assert new_df.filter(new_df["departure_time"].isNull()).count() == 0


def test_time_added(spark):
    originalValue = [(10, '2019-12-21 09:15:32')]
    expectedValue = [(10, '2019-12-21 09:25:32')]
    df = spark.createDataFrame(originalValue, ['DELAY', 'START_DATE'])
    df = transformation.parse_to_datetime_column(df, 'START_DATE', 'yyyy-MM-dd HH:mm:ss')
    expected = spark.createDataFrame(expectedValue, ['ID', 'START_DATE'])
    expected = transformation.parse_to_datetime_column(expected, 'START_DATE', 'yyyy-MM-dd HH:mm:ss')

    newDF = transformation.add_time(df, 'START_DATE', minutes='DELAY')

    assert newDF.select('START_DATE').collect()[0] == expected.select('START_DATE').collect()[0]
