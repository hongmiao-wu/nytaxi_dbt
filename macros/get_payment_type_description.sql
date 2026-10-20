{#
    Turns the numeric payment_type code into a readable description.
#}

{% macro get_payment_type_description(payment_type) -%}

    case cast({{ payment_type }} as integer)
        when 0 then 'Flex Fare trip'
        when 1 then 'Credit card'
        when 2 then 'Cash'
        when 3 then 'No charge'
        when 4 then 'Dispute'
        when 5 then 'Unknown'
        when 6 then 'Voided trip'
        else 'Unknown'
    end

{%- endmacro %}