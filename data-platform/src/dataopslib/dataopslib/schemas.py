#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Main module."""

from pyspark.sql.types import (StructType, StructField, StringType, IntegerType, DoubleType, ShortType)


def get_schema(schema_name):

    if schema_name == 'sample_schema':
        schema = StructType([
            StructField('ID', IntegerType()),
            StructField('START_DATE', StringType()),
            StructField('END_DATE', StringType()),
        ])

    if schema_name == 'AirportCodeSchema':
        schema = StructType([
            StructField('AIRPORT_ID', IntegerType()),
            StructField('AIRPORT', StringType()),
            StructField('DISPLAY_AIRPORT_NAME', StringType()),
            StructField('LATITUDE', DoubleType()),
            StructField('LONGITUDE', DoubleType()),
        ])

    if schema_name == 'FlightDelaysSchema':
        schema = StructType([
            StructField('Year', IntegerType()),
            StructField('Month', IntegerType()),
            StructField('DayofMonth', IntegerType()),
            StructField('DayOfWeek', IntegerType()),
            StructField('Carrier', StringType()),
            StructField('CRSDepTime', IntegerType()),
            StructField('DepDelay', IntegerType()),
            StructField('DepDel15', ShortType()),
            StructField('CRSArrTime', IntegerType()),
            StructField('ArrDelay', IntegerType()),
            StructField('ArrDel15', ShortType()),
            StructField('Cancelled', ShortType()),
            StructField('OriginAirportCode', StringType()),
            StructField('OriginAirportName', StringType()),
            StructField('OriginLatitude', DoubleType()),
            StructField('OriginLongitude', DoubleType()),
            StructField('DestAirportCode', StringType()),
            StructField('DestAirportName', StringType()),
            StructField('DestLatitude', DoubleType()),
            StructField('DestLongitude', DoubleType()),
        ])

    return schema
