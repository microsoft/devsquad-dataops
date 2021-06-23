#!/usr/bin/env python
# -*- coding: utf-8 -*-

from pyspark.sql import SparkSession
try:
    import dataopslib.schemas as schemas
    import dataopslib.spark.data_transformation as transformation
except ImportError:
    import os
    import sys
    cur_dir = os.path.dirname(__file__)
    # Add the parent directory in the search for modules when importing
    sys.path.append(os.path.abspath(os.path.join(cur_dir, os.pardir)))
    import dataopslib.schemas as schemas
    import dataopslib.spark.data_transformation as transformation

spark = SparkSession.builder\
    .master("local")\
    .appName("sample_read_csv.py")\
    .getOrCreate()
spark.sparkContext.setLogLevel("ERROR")

schema = schemas.get_schema("sample_schema")
df = spark.read.csv("./data/sample_data.csv", header=True, schema=schema)

print("Original data sample...")
df.show()

print("Running date timezone transformations")
newDF = transformation.transform_date_time_zone(df, "START_DATE",
                                                    "America/Sao_Paulo")

print("Running unixtime column agg")
newDF = transformation.add_unixtime_column(df, "START_DATE",
                                           'MM/dd/yyyy HH:mm:ss', 'START_DATE_UNIX')

print("Dropping duplicates rows")
newDF = transformation.drop_duplicates_rows(newDF, "ID")

print("Dropping some columns")
newDF = transformation.drop_columns(newDF, "ID")

print("Here is what I got after running some transformation...")
newDF.show()
