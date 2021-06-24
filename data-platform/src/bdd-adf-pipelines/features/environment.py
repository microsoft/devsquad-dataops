from typing import Any
from core.models import ServicePrincipal
from core.services import Adls, DataFactory
import os

# Service principal environment variables
client_id: str = os.getenv('CLIENT_ID')
client_secret: str = os.getenv('CLIENT_SECRET')
subscription_id: str = os.getenv('SUBSCRIPTION_ID')
tenant_id: str = os.getenv('TENANT_ID')

# Data Factory environment variables
adf_name: str = os.getenv('ADF_NAME')
resource_group_name: str = os.getenv('RESOURCE_GROUP_NAME')

# ADLS environment variables
storage_account_name: str = os.getenv('STORAGE_ACCOUNT_NAME')
storage_account_key: str = os.getenv('STORAGE_ACCOUNT_KEY')

# Pipelines
pipelines: list = ["ProcessFlightsDelaysData"]

def before_all(context: Any) -> None:
  print("Starting the execution of data pipelines...\n")

  adf: DataFactory = setup_data_factory(context)
  _ = run_pipelines(adf, context)
  _ = setup_adls(context)

def setup_data_factory(context: Any) -> None:
  service_principal = ServicePrincipal(client_id, client_secret, subscription_id, tenant_id)
  adf = DataFactory(adf_name, resource_group_name, service_principal)

  if not adf.exists():
    raise Exception(f"The data factory '{adf_name}' could not be found.")

  return adf

def run_pipelines(adf: DataFactory, context: Any) -> None:
  pipeline_results: dict = {}
  
  # Run all pipelines
  for pipeline in pipelines:
    pipeline_results[pipeline] = adf.run_pipeline(pipeline)

  context.pipeline_results = pipeline_results

def setup_adls(context: Any) -> None:
  context.adls = Adls(storage_account_name, storage_account_key)
