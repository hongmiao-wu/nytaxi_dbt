/*
The fact trips model is left as an exercise. 

Here's what's expected:

0. One row per trip — yellow and green combined (the union is already done in the intermediate model)
1. Add a primary key (trip_id) — it has to be unique
2. Find and fix duplicates — there are quite a few in this dataset.  Some come from the source, some get introduced during the union. 
Find them, understand why they happen, and fix them
3. (done) Enrich payment_type (there is a seed for this in the repo).

*/


/*
Step 1: Create a primary key (trip_id) for the fct_trips model.  
This is a unique identifier for each trip.  
It can be a hash of the pickup_datetime, dropoff_datetime, and vendorid, or any other combination of fields that will guarantee uniqueness.

Here we use columns service_type, pickup_datetime, dropoff_datetime, vendorid, pickup_location_id, and dropoff_location_id to create a unique trip_id.

To generate a surrogate key, we can use the dbt_utils, thus lets create a package.yml file in the root of the project and add dbt_utils as a dependency.  
Then run uv run dbt deps to install the package.

Then we can use the generate_surrogate_key macro to create a unique trip_id for each trip.
*/

{{ config(materialized='table') }}

with keyed as (
    select
        {{ dbt_utils.generate_surrogate_key([
            'service_type',
            'vendorid',
            'pickup_datetime',
            'dropoff_datetime',
            'pickup_locationid',
            'dropoff_locationid'
        ]) }} as trip_id,
        *
    from {{ ref('int_trips_unioned') }}
),


/*
Step 2: Find and fix duplicates

Step 2.1: Find duplicates
to find how many duplicates there are, we can run the following query:
'''
select
    count(*) as total_rows,
    count(distinct trip_id) as distinct_trip_ids,
    count(*) - count(distinct trip_id) as extra_rows
from `dte-course-509515.nytaxi_dataset.fct_trips`;
'''

total rows: 114827251
distinct_trip_ids: 114562355
extra rows: 264896

Step 2.2: Are the duplicates exact the same or do they differ in some columns?
Since we only picked a few columns to generate the trip_id, there might be some duplicates that differ in other columns.

'''
with _group as (
    select
        trip_id,
        count(*) as n_rows,
        count(distinct to_json_string(f)) as n_distinct_versions
    from `dte-course-509515.nytaxi_dataset.fct_trips` f
    group by trip_id
    having count(*) > 1
)
select
    countif(n_distinct_versions = 1) as exact_copies,
    countif(n_distinct_versions > 1) as same_key_different_rows
from _group;
'''

exact copies: 67
same key different rows: 264773

Step 2.3: For those exact copies, we can just keep one of them.  
*/

-- remove exact copies (rows identical in every column)
exact_copies_removed as (
    select distinct *
    from keyed
)

select * from exact_copies_removed
/*


For those with the same key but different rows, we need to investigate further to see which one to keep.

Step 2.4: count how often each column is the one that differs
'''
with groups as (
    select
        trip_id,
        count(distinct ifnull(cast(passenger_count as string), 'null')) > 1 as passenger_count_differs,
        count(distinct ifnull(cast(trip_distance as string), 'null')) > 1 as trip_distance_differs,
        count(distinct ifnull(cast(ratecodeid as string), 'null')) > 1 as ratecodeid_differs,
        count(distinct ifnull(cast(fare_amount as string), 'null')) > 1 as fare_amount_differs,
        count(distinct ifnull(cast(total_amount as string), 'null')) > 1 as total_amount_differs,
        count(distinct ifnull(cast(payment_type as string), 'null')) > 1 as payment_type_differs
    from `dte-course-509515.nytaxi_dataset.fct_trips`
    group by trip_id
    having count(*) > 1
)
select
    countif(passenger_count_differs) as passenger_count,
    countif(trip_distance_differs) as trip_distance,
    countif(ratecodeid_differs) as ratecodeid,
    countif(fare_amount_differs) as fare_amount,
    countif(total_amount_differs) as total_amount,
    countif(payment_type_differs) as payment_type
from groups;
'''
[{
  "passenger_count": "123",
  "trip_distance": "205",
  "ratecodeid": "14",
  "fare_amount": "264657",
  "total_amount": "264740",
  "payment_type": "232049"
}]

The money differs in nearly every case. the payment type in most of them.

Step 2.5
'''
with dup as (
    select
        trip_id,
        countif(fare_amount < 0) as negative_rows,
        countif(fare_amount > 0) as positive_rows,
        countif(fare_amount = 0) as zero_rows
    from `dte-course-509515.nytaxi_dataset.fct_trips`
    group by trip_id
    having count(*) > 1
)
select negative_rows, positive_rows, zero_rows, count(*) as _groups
from dup
group by 1, 2, 3
order by _groups desc
limit 10;
'''
Out of about 264,840 duplicate groups, 264,177 (roughly 99.7%) are exactly one positive row and one negative row, 
which fits an original trip plus its reversal (a refund or dispute). The rest are small side cases:

*/