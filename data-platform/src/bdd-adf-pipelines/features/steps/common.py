from behave import given
from typing import Any

@given('successful execution of the "{pipeline_name}" data pipeline')
def step_impl(context: Any, pipeline_name: str) -> None:
  if pipeline_name in context.pipeline_results.keys():
      assert context.pipeline_results[pipeline_name] is True
  else:
    raise Exception(f"The data pipeline '{pipeline_name}' was not configured on environments.py to be executed.")
