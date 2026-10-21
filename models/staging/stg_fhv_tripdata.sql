with tripdata as (
  select *
  from {{ source('staging','fhv_tripdata_all_partitioned') }}
  where dispatching_base_num is not null
),

renamed as (
  select
      cast(dispatching_base_num as string) as dispatching_base_num,
      cast(pickup_datetime as timestamp) as pickup_datetime,
      cast(dropOff_datetime as timestamp) as dropoff_datetime,
      cast(PUlocationID as integer) as pickup_location_id,
      cast(DOlocationID as integer) as dropoff_location_id,
      cast(SR_Flag as integer) as sr_flag,
      cast(Affiliated_base_number as string) as affiliated_base_number
  from tripdata
)

select * from renamed
