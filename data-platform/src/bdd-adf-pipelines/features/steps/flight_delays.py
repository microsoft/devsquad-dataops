from typing import Any, List, Optional
from behave import given, then
import csv
from io import StringIO

@given('the "{container_name}" container exists in the data lake')
def check_if_adls_container_exists(context: Any, container_name: str) -> None:
  container_exists: bool = context.adls.container_exists(container_name)
  context.container_name = container_name
  assert container_exists is True

@then('at least {min_flights:d} flights must exist for all airports')
def check_if_flights_exist(context: Any, min_flights: int) -> None:
  log_content: str = context.adls.get_latest_log_content(context.container_name, "logs")
  reader = get_csv_reader(log_content)

  for row in reader:
    airport_flights: int = int(row[1])
    assert airport_flights > min_flights

def get_csv_reader(log_content: str):
  file_content = StringIO(log_content)
  reader = csv.reader(file_content, delimiter=',')
  headers: Optional(List[str]) = next(reader, None)

  if not headers:
    raise Exception("The log file has no content.")

  return reader
