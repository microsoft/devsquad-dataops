from typing import Any, Dict, List
from xml.etree import ElementTree
from xml.dom import minidom
from xml.etree.ElementTree import Element, SubElement, Comment
import sys, json

def prettify_test_suites_to_xml(test_suites: Element) -> str:
	rough_string: str = ElementTree.tostring(test_suites, 'utf-8')
	reparsed: str = minidom.parseString(rough_string)
	return reparsed.toprettyxml(indent="  ")

def create_test_case_attrib(test: Any) -> Dict[str, Any]:
  return {
		'classname': test['classname'],
		'name': f"{test['step']['keyword']} {test['step']['name']}",
		'time': str(test['step']['result']['duration'])
  }

def create_error_test_case_attrib(failed_test: Any) -> Dict[str, str]:
  return {
		'message': ' '.join(failed_test['step']['result']['error_message']),
		'type': 'exception'
	}

def create_failed_test_case(test_suite, failed_test: Any) -> Element:
  test_case_attributes: Dict[str, Any] = create_test_case_attrib(failed_test)
  test_case: Element = SubElement(test_suite, 'testcase', test_case_attributes)
  error_test_case_attrib: Dict[str, str] = create_error_test_case_attrib(failed_test)
  
  return SubElement(test_case, 'error', error_test_case_attrib)

def create_passed_test_case(test_suite, passed_test: Any) -> Element:
	test_case_attrib: Dict[str, Any] = create_test_case_attrib(passed_test)
	return SubElement(test_suite, 'testcase', test_case_attrib)

def create_test_suite(test_suites: Element, test_suite_attributes: Dict[str, str]) -> Element:
  return SubElement(test_suites, 'testsuite', test_suite_attributes)

def test_passed(step: Any) -> bool:
  return step['result']['status'] == 'passed'

def append_test_suite(test_suites: Element, feature: Any) -> None:
  passed_tests: List[Dict[str, Any]] = []
  failed_tests: List[Dict[str, Any]] = []
  total_tests_duration_seconds: float = 0.0

  scenarios: List[Any] = [element for element in feature['elements'] if element['type'] == 'scenario']

  for scenario in scenarios:
    steps_with_results: List[Any] = [step for step in scenario['steps'] if 'result' in step.keys()]

    for step in steps_with_results:
      test: Dict[str, Any] = {'classname': scenario['name'], 'step': step}
      
      if test_passed(step):
        passed_tests.append(test)
      else:
        failed_tests.append(test)
      
      total_tests_duration_seconds = total_tests_duration_seconds + step['result']['duration'] 

  test_suite_attributes: Dict[str, str] = {
		'id': '1',
		'name': feature['name'],
		'hostname': 'Azure DevOps',
		'time': str(total_tests_duration_seconds),
		'tests': str(sum([len(scenario['steps']) for scenario in scenarios])),
		'failures': str(len(failed_tests))
	}

  test_suite: Element = create_test_suite(test_suites, test_suite_attributes)

  for failed_test in failed_tests:
    _: Element = create_failed_test_case(test_suite, failed_test)

  for passed_test in passed_tests:
    _: Element = create_passed_test_case(test_suite, passed_test)
    
def create_test_suites(behave_file_path: str) -> str:
  test_suites = Element('testsuites')

  with open(behave_file_path) as behave_file:
    features: List[Any] = json.load(behave_file)
    
    for feature in features:
      append_test_suite(test_suites, feature)

  return prettify_test_suites_to_xml(test_suites)

def main():
  print('Converting...')

  behave_test_results_file: str = sys.argv[1]
  junit_output_file_path: str = sys.argv[2]

  with open(junit_output_file_path, "w") as junit_output_file:
    junit_test_suites: str = create_test_suites(behave_test_results_file)
    junit_output_file.write(junit_test_suites)

  print('Done!')
    
if __name__ == '__main__':
	main()
