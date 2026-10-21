{{ config(materialized='table') }}

with trips as (
    select * from {{ ref('fct_trips') }}
),

zones as (
    select * from {{ ref('dim_zones') }}
)

select
    -- grouping columns
    coalesce(z.zone, 'Unknown') as revenue_zone,
    date_trunc(date(t.pickup_datetime), month) as revenue_month,
    t.service_type,

    -- revenue breakdown
    sum(t.fare_amount) as revenue_monthly_fare,
    sum(t.extra) as revenue_monthly_extra,
    sum(t.mta_tax) as revenue_monthly_mta_tax,
    sum(t.tip_amount) as revenue_monthly_tip_amount,
    sum(t.tolls_amount) as revenue_monthly_tolls_amount,
    sum(t.ehail_fee) as revenue_monthly_ehail_fee,
    sum(t.improvement_surcharge) as revenue_monthly_improvement_surcharge,
    sum(t.congestion_surcharge) as revenue_monthly_congestion_surcharge,
    sum(t.total_amount) as revenue_monthly_total_amount,

    -- additional metrics
    count(t.trip_id) as total_monthly_trips,
    avg(t.passenger_count) as avg_monthly_passenger_count,
    avg(t.trip_distance) as avg_monthly_trip_distance

from trips t
left join zones z
    on t.pickup_locationid = z.location_id
group by 1, 2, 3