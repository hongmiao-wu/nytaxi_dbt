-- tests/assert_positive_fare_amount.sql
-- Fare amounts should always be positive

select
    vendorid,
    fare_amount
from {{ ref('int_trips_unioned') }}
where fare_amount <= 0