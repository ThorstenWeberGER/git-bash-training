#!/usr/bin/env bash
set -euo pipefail

ask_name() {
    echo "What is your name?"
    read -r name
    echo "Hello, $name!"
}

# function read_list_names() will read the file list_names.txt and print each name to console
read_list_names() {
    while IFS= read -r name; do
        echo "Hello, $name!"
    done < list_names.txt
}

# read list_names.txt into an array
mapfile -t liste < list_names.txt

# function iterating over array
do_iterate() {
        for item in "${liste[@]}"; do
          echo "$item"
        done
}

# function showing second item (index 1, since arrays start at 0)
do_second() {
        echo "${liste[1]}"
}

# function to read comma-separated values from list_names.csv and print each line
read_csv_names() {
    # tail -n +2 skips the header row (starts from line 2)
    # tr -d '\r' removes Windows line endings. note tr can -d delete characters. tr can also replace characters, e.g. tr 'a-z' 'A-Z' would convert lowercase to uppercase
    # IFS=, tells bash to split each line by commas
    # _ is a throwaway variable (we don't use lastname)
    # read is used to read each line into variables firstname, lastname, and city, -r prevents backslash escapes from being interpreted
    tail -n +2 list_names.csv | tr -d '\r' | while IFS=, read -r firstname _ city; do
        echo "Hello, $firstname from $city!"
    done
}

# show content of list_names.csv only first column, second column and starting with row 2, skip the header row
show_csv_names() {
    # cut -d, -f1,3 selects the first and third columns (firstname and city)
    tail -n +2 list_names.csv | 
        tr -d '\r' | 
        cut -d, -f1,3 | 
        while IFS=, read -r firstname city; 
        do
            echo "Hello, $firstname from $city!"
        done
}

# call the functions
# do_iterate
# echo "---"
# do_second
# echo "---"
# ask_name
# echo "---"
# read_list_names
# echo "---"
# read_csv_names

show_csv_names