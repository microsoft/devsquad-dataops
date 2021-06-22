#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Tests for `dataopslib.data_quality` module."""

import pytest
import operator
try:
    import dataopslib.spark.data_quality as quality
    import dataopslib.schemas as schemas
except ImportError:
    import os
    import sys
    cur_dir = os.path.dirname(__file__)
    # Add the parent directory in the search for modules when importing
    sys.path.append(os.path.abspath(os.path.join(cur_dir, os.pardir)))
    import dataopslib.spark.data_quality as quality
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


def test_has_null(spark):

    schema = schemas.get_schema("sample_schema")
    df = spark.read.csv("./data/sample_data.csv", header=True, schema=schema)

    cols = ['END_DATE', 'START_DATE']
    has_null = quality.has_null(df, cols)

    assert has_null is False


def test_has_invalid_dates(spark):

    schema = schemas.get_schema("sample_schema")
    df = spark.read.csv("./data/sample_data.csv", header=True, schema=schema)

    cols = ['END_DATE', 'START_DATE']
    has_invalid_dates = quality.has_invalid_dates(df, cols, 'MM/dd/yyyy HH:mm:ss')

    assert has_invalid_dates is False


def test_has_inconsistent_dates_operator_gt(spark):
    schema = schemas.get_schema("sample_schema")
    df = spark.read.csv("./data/sample_data.csv", header=True, schema=schema)

    has_inconsistent_dates = quality.has_inconsistent_dates(df, 'START_DATE', 'END_DATE',
                                                            'MM/dd/yyyy HH:mm:ss',
                                                            operator.gt)

    assert has_inconsistent_dates is False


def test_has_inconsistent_dates_operator_lt(spark):
    schema = schemas.get_schema("sample_schema")
    df = spark.read.csv("./data/sample_data.csv", header=True, schema=schema)

    has_inconsistent_dates = quality.has_inconsistent_dates(df, 'START_DATE', 'END_DATE',
                                                            'MM/dd/yyyy HH:mm:ss',
                                                            operator.lt)

    assert has_inconsistent_dates is True
