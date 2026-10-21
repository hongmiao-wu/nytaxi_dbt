/*

keyed is every column of int_trips_unioned plus a new trip_id column at the front, and the distinct right after it removes the exact copies.

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
)

select distinct * from keyed