#!/usr/bin/env python
# -*- coding: utf-8 -*-

from pyspark.sql import SparkSession
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


spark = SparkSession.builder\
    .master("local")\
    .appName("sample_has_inconsistent_dates.py")\
    .getOrCreate()
spark.sparkContext.setLogLevel("ERROR")

schema = schemas.get_schema("sample_schema")
df = spark.read.csv("./data/sample_data.csv", header=True, schema=schema)

has_inconsistent_dates = quality.has_inconsistent_dates(df, 'START_DATE', 'END_DATE',
                                                        'MM/dd/yyyy HH:mm:ss',
                                                        operator.gt)
if has_inconsistent_dates:
    print("The dataframe has START_DATE greater than END_DATE in the columns")
else:
    print("The dataframe doesn't have START_DATE greater than END_DATE in the columns")
