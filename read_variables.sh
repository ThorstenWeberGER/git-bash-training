#!/usr/bin/bash

# ask user for Snowflake account, warehouse, database, schema and store in an array
read_snowflake_variables() {
    # ask user for each variable
    echo "Enter your Snowflake account:"
    read snowflake_account
    echo "Enter your Snowflake warehouse:"
    read snowflake_warehouse
    echo "Enter your Snowflake database:"
    read snowflake_database
    echo "Enter your Snowflake schema:"
    read snowflake_schema

    # store the variables in an array
    snowflake_vars=("$snowflake_account" "$snowflake_warehouse" "$snowflake_database" "$snowflake_schema")

    echo "Snowflake variables stored in array: ${snowflake_vars[@]}"
}

read_snowflake_variables