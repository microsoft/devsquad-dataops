# Databricks notebook source

# Installing Library DataOpsLib
print("Library to install ... " + dbutils.fs.ls("dbfs:/FileStore/pypi-libs/new_version/")[0][0])
dbutils.library.install(dbutils.fs.ls("dbfs:/FileStore/pypi-libs/new_version/")[0][0])

# COMMAND ----------

import datetime
from pyspark.sql.types import *
from pyspark.sql import functions as F

# COMMAND ----------

from dataopslib.spark import data_transformation as transformation

# COMMAND ----------

### Preparing delays data
flight_delays_df = spark.read.format('csv').options(
    header='true', inferschema='true').load("/mnt/landing/flight-delays/FlightDelaysWithAirportCodes.csv")

# COMMAND ----------

# Create a column departure_time with the actual departure time, which requires combining the date columns, parse the time in military format
# and add the departure delay (in minutes) to the time
flight_delays_df = transformation.cast_columns(flight_delays_df, 'string', columns=['CRSDepTime'])
flight_delays_df = flight_delays_df.withColumn('CRSDepTime', F.lpad(F.col('CRSDepTime'), 4, '0'))
flight_delays_df = flight_delays_df.fillna({'DepDelay': 0})
flight_delays_df = transformation.make_datetime_column(flight_delays_df, 'departure_time', 'Year', 'Month', 'DayofMonth',
                                                       time='CRSDepTime', timeFormat='Hmm')
flight_delays_df = transformation.add_time(flight_delays_df, 'departure_time', minutes='DepDelay')

# COMMAND ----------

flight_delays_df.createOrReplaceTempView('flight_delays_with_airport_codes')

# COMMAND ----------

query = "SELECT OriginAirportCode, OriginLatitude, OriginLongitude, \
            Month, DayofMonth, cast(CRSDepTime as long) CRSDepTime, \
            DayOfWeek, Carrier, DestAirportCode, DestLatitude, \
            DestLongitude, cast(DepDel15 as int) DepDel15, departure_time \
        FROM flight_delays_with_airport_codes"

# Select only the columns we need, casting CRSDepTime as long and DepDel15 as int, into a new DataFrame
dfflights = spark.sql(query)

# Delete rows containing missing values
dfflights = dfflights.na.drop()

# Round departure times down to the nearest hour, and export the result as a new column named "CRSDepHour"
dfflights = dfflights.withColumn('CRSDepHour', F.floor(dfflights['CRSDepTime'] / 100))

# Trim the columns to only those we will use for the predictive model
dfflightsClean = dfflights.select(
    "OriginAirportCode", "OriginLatitude", "OriginLongitude", "Month",
    "DayofMonth", "CRSDepHour", "DayOfWeek", "Carrier", "DestAirportCode",
    "DestLatitude", "DestLongitude", "DepDel15")

dfflightsClean.createOrReplaceTempView('flight_delays_view')

# COMMAND ----------

dfFlightDelays_Clean = spark.sql("select * from flight_delays_view")
dfFlightDelays_Clean.write.mode("overwrite").saveAsTable("flight_delays_clean")

# COMMAND ----------

# Preparing weather data
flight_delays_df = spark.read.format('csv').options(
    header='true', inferschema='true').load("/mnt/landing/flight-weather/FlightWeatherWithAirportCode.csv")

flight_delays_df.createOrReplaceTempView('flight_weather_with_airport_code')
dfWeather = spark.sql("SELECT AirportCode, cast(Month as int) Month, cast(Day as int) Day, \
                            cast(Time as int) Time, WindSpeed, SeaLevelPressure, HourlyPrecip \
                        FROM flight_weather_with_airport_code")

# COMMAND ----------

# Round Time down to the next hour, since that is the hour for which we want to use flight data. Then, add the rounded Time to a new column named "Hour", and append that column to the dfWeather DataFrame.
df = dfWeather.withColumn('Hour', F.floor(dfWeather['Time'] / 100))

# Replace any missing HourlyPrecip and WindSpeed values with 0.0
df = df.fillna('0.0', subset=['HourlyPrecip', 'WindSpeed'])

# Replace any WindSpeed values of "M" with 0.005
df = df.replace('M', '0.005', 'WindSpeed')

# Replace any SeaLevelPressure values of "M" with 29.92 (the average pressure)
df = transformation.replace_with_agg(df, 'SeaLevelPressure', 'M', F.avg)

# Replace any HourlyPrecip values of "T" (trace) with 0.005
df = df.replace('T', '0.005', 'HourlyPrecip')

# Be sure to convert WindSpeed, SeaLevelPressure, and HourlyPrecip columns to float
# Define a new DataFrame that includes just the columns being used by the model, including the new Hour feature
dfWeather_Clean = transformation.cast_columns(df, 'float', columns=['SeaLevelPressure', 'WindSpeed', 'HourlyPrecip'])\
                                .select('AirportCode', 'Month', 'Day', 'Hour', 'WindSpeed', 'SeaLevelPressure', 'HourlyPrecip')

# COMMAND ----------

dfWeather_Clean.write.mode("overwrite").saveAsTable("flight_weather_clean")

# COMMAND ----------

dfFlightDelaysWithWeather = spark.sql("SELECT d.OriginAirportCode, \
                                            d.Month, d.DayofMonth, d.CRSDepHour, d.DayOfWeek, \
                                            d.Carrier, d.DestAirportCode, d.DepDel15, w.WindSpeed, \
                                            w.SeaLevelPressure, w.HourlyPrecip \
                                            FROM flight_delays_clean d \
                                            INNER JOIN flight_weather_clean w ON \
                                            d.OriginAirportCode = w.AirportCode AND \
                                            d.Month = w.Month AND \
                                            d.DayofMonth = w.Day AND \
                                            d.CRSDepHour = w.Hour")

# COMMAND ----------

dfFlightDelaysWithWeather.count()

# COMMAND ----------

dfFlightDelaysWithWeather.write.mode("overwrite").parquet("/mnt/trusted/flight-delays-with-weather")

# COMMAND ----------

import os
fp_logs = '/dbfs/mnt/trusted/logs'
if not os.path.exists(fp_logs):
    os.mkdir(fp_logs)

fp_trace = os.path.join(fp_logs, datetime.datetime.now().strftime("log_train_set_%Y%m%d_%H%M%S.csv"))

# COMMAND ----------

trace_df = dfFlightDelaysWithWeather.groupBy(["OriginAirportCode"]).agg(F.count('DepDel15').alias('count'))
trace_df.toPandas().to_csv(fp_trace, index=False)

# COMMAND ----------

dbutils.notebook.exit(fp_trace)