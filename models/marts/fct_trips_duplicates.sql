{{ config(materialized='table') }}

with ranked as (
    select
        *,
        count(*) over (partition by trip_id) as rows_in_group,
        row_number() over (
            partition by trip_id
            order by fare_amount desc, total_amount desc, payment_type
        ) as dup_rank
    from {{ ref('int_trips_keyed') }}
)

select *
from ranked
where rows_in_group > 1