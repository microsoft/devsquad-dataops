#!/usr/bin/env python
# -*- coding: utf-8 -*-

from pyspark.sql import SparkSession
try:
    import dataopslib.schemas as schemas
except ImportError:
    import os
    import sys
    cur_dir = os.path.dirname(__file__)
    # Add the parent directory in the search for modules when importing
    sys.path.append(os.path.abspath(os.path.join(cur_dir, os.pardir)))
    import dataopslib.schemas as schemas

spark = SparkSession.builder\
    .master("local")\
    .appName("sample_read_csv.py")\
    .getOrCreate()
spark.sparkContext.setLogLevel("ERROR")

schema = schemas.get_schema("AirportCodeSchema")
df = spark.read.csv("./data/AirportCodeLocationLookupClean.csv", header=True, schema=schema)
df.printSchema()
df.show()

schema = schemas.get_schema("FlightDelaysSchema")
df = spark.read.csv("./data/FlightDelaysWithAirportCodes.csv", header=True, schema=schema)
df.printSchema()
df.show()
