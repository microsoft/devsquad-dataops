"""This modules contains UDF functions that expands the regular Spark SQL language capabilities.
"""
import datetime
import logging
from dateutil.tz import tzlocal

from pyspark.sql.types import TimestampType

logger = logging.getLogger(__name__)

try:
    from pyspark.sql import SparkSession
    _spark = SparkSession.builder.getOrCreate()

    add_seconds = _spark.udf.register("add_seconds",
                                      lambda dt, seconds: (dt + datetime.timedelta(seconds=int(seconds))).replace(tzinfo=tzlocal()),
                                      returnType=TimestampType())

    add_minutes = _spark.udf.register("add_minutes",
                                      lambda dt, minutes: (dt + datetime.timedelta(minutes=int(minutes))).replace(tzinfo=tzlocal()),
                                      returnType=TimestampType())

    add_hours = _spark.udf.register("add_hours",
                                    lambda dt, hours: (dt + datetime.timedelta(hours=int(hours))).replace(tzinfo=tzlocal()),
                                    returnType=TimestampType())
except ImportError:
    logger.error('Spark is not available in this context. This module functionality will be limited')
