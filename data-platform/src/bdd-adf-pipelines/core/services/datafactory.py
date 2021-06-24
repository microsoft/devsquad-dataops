from azure.identity import ClientSecretCredential
from azure.mgmt.datafactory import DataFactoryManagementClient
from azure.mgmt.datafactory.models import ActivityRunsQueryResponse, CreateRunResponse, Factory, PipelineRun, RunFilterParameters
from core.models import ServicePrincipal
from datetime import datetime, timedelta
from typing import Optional
import time

class DataFactory:
  def __init__(self, adf_name: str, resource_group_name: str, service_principal: ServicePrincipal) -> None:
    self.factory_name: str = adf_name
    self.resource_group_name: str = resource_group_name
    self.service_principal: ServicePrincipal = service_principal
    self.client: DataFactoryManagementClient = self.get_client()
    
  def get_client(self) -> DataFactoryManagementClient:
    credentials = ClientSecretCredential(
      client_id=self.service_principal.client_id, 
      client_secret=self.service_principal.client_secret, 
      tenant_id=self.service_principal.tenant_id)
      
    return DataFactoryManagementClient(credentials, self.service_principal.subscription_id)

  def exists(self) -> bool:
    factory: Optional[Factory] = self.client.factories.get(self.resource_group_name, self.factory_name)
    return factory != None

  def run_pipeline(self, pipeline_name: str) -> bool:
    run_id: str = self.get_run_id(pipeline_name)
    pipeline_run: PipelineRun = self.get_pipeline_run(run_id)
    pipeline_run_status: str = self.get_pipeline_run_status(pipeline_run)

    while pipeline_run_status != 'Succeeded':
      if pipeline_run_status == 'Failed':
        return False

      pipeline_run_status = self.get_pipeline_run_status(pipeline_run)

    return True

  def get_run_id(self, pipeline_name: str) -> str:
    run_response: CreateRunResponse = self.client.pipelines.create_run(
      resource_group_name=self.resource_group_name, 
      factory_name=self.factory_name, 
      pipeline_name=pipeline_name, 
      parameters={})

    return run_response.run_id

  def get_pipeline_run(self, run_id: str) -> PipelineRun:
    return self.client.pipeline_runs.get(self.resource_group_name, self.factory_name, run_id)

  def get_query_response(self, pipeline_run: PipelineRun) -> ActivityRunsQueryResponse:
    last_updated_after: datetime = datetime.now() - timedelta(1)
    last_updated_before: datetime = datetime.now() + timedelta(1)
    filter_params = RunFilterParameters(last_updated_after=last_updated_after, last_updated_before=last_updated_before)

    return self.client.activity_runs.query_by_pipeline_run(
      self.resource_group_name, self.factory_name, pipeline_run.run_id, filter_params)

  def get_pipeline_run_status(self, pipeline_run: PipelineRun) -> str:
    query_response: ActivityRunsQueryResponse = self.get_query_response(pipeline_run)
    
    while not query_response.value:
      query_response = self.get_query_response(pipeline_run)
      time.sleep(1)

    return query_response.value[0].status
