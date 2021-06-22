Feature: Flight Delays
  The data pipeline serves weather and flight delay data for:
    - Auditing purposes
    - Data scientists, enabling them to produce flight delay predictions for customers
    - BI analysts, enabling them to analyze the costs of flight delays over time.
  
  Background:
    Given successful execution of the "ProcessFlightsDelaysData" data pipeline
    
    Scenario: Weather and flight delay transformed data for data scientists
      Given the "trusted" container exists in the data lake
      Then at least 100 flights must exist for all airports
