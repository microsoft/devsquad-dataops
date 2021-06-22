# Databricks notebook source
# Databricks notebook source
import os
for adls_zone in ["landing", "refined", "trusted"]:
    if not os.path.exists("/dbfs/mnt/{}/".format(adls_zone)):
        mount_point = "/mnt/{}".format(adls_zone)
        configs = {
            "fs.azure.account.auth.type": "OAuth",
            "fs.azure.account.oauth.provider.type": "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider",
            "fs.azure.account.oauth2.client.id": dbutils.secrets.get(scope="dataops", key="clientId"),
            "fs.azure.account.oauth2.client.secret": dbutils.secrets.get(scope="dataops", key="clientSecret"),
            "fs.azure.account.oauth2.client.endpoint": "https://login.microsoftonline.com/{}/oauth2/token".format(dbutils.secrets.get(scope="dataops", key="tenantId")),
            "fs.azure.createRemoteFileSystemDuringInitialization": "true"
        }
        dbutils.fs.mount(
            source="abfss://{}@{}.dfs.core.windows.net".format(adls_zone, dbutils.secrets.get(scope="dataops", key="dataLakeName")),
            mount_point=mount_point,
            extra_configs=configs)
