# NYC Taxi dbt project

This project is a dbt exercise based on the [Data Engineering Zoomcamp — Analytics Engineering homework](https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/04-analytics-engineering).

The goal is to take raw taxi trip data already loaded into BigQuery, transform it with dbt, and prepare a cleaner analytical layer for reporting and exploration.

## Data sources

The raw data comes from the [DataTalksClub NYC TLC datasets](https://github.com/DataTalksClub/nyc-tlc-data/) used in the course, using static source files rather than the live TLC tables so the dataset stays stable over time.

Relevant sources in this project include:

- green_tripdata_all_partitioned
- yellow_tripdata_all_partitioned
- taxi_zone_lookup

## Transformation flow

The dbt project is organized around a simple structure:

- models/staging: source cleanup and standardization
- models/intermediate: unioned trip data and other shared transformations
- models/marts: final presentation-ready tables

A few examples from this project:

- stg_green_tripdata.sql and stg_yellow_tripdata.sql normalize the source schema
- int_trips_unioned.sql combines the green and yellow trip records into a single table
- dim_zones.sql creates a dimension table with borough and zone metadata

## Tools and setup

This project was built with the following workflow:

1. **Airflow** was used locally to ingest the data
2. Data was stored in **GCP Cloud Storage** / loaded into **BigQuery**
3. **dbt** was used locally to model and transform the warehouse data

## Purpose

The main purpose of the project is to practice the analytics engineering workflow: turning raw, operational data into a structured model that is easier to query, analyze, and build reports on.

For the final business-facing layer, see the comments in the models under the marts directory.
