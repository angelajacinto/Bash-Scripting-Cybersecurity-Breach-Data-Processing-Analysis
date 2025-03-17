#!/usr/bin/env bash

#!/usr/bin/env bash

# -------------------------------
# Cybersecurity Breach Analysis Script
# Description: This script processes a tab-separated values (TSV) file
# containing cybersecurity breach data and extracts useful insights.
# It works on both macOS and Windows Git Bash without modifying the TSV file.
# -------------------------------

# -------------------------------
# CHECKING INPUT ARGUMENTS
# -------------------------------

# Ensure the user provides exactly two arguments
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <TSV data file> <maxstate | maxyear | <year> | <state>>"
    exit 1
fi

# Store input arguments in variables
file="$1"    # First argument: File name
query="$2"   # Second argument: Command (maxstate, maxyear, year, or state)

# -------------------------------
# FILE EXISTENCE & VALIDITY CHECK
# -------------------------------

# Check if the file exists and is not empty
if [[ ! -f "$file" || ! -s "$file" ]]; then
    echo "Error: File '$file' does not exist or is empty."
    exit 1
fi

# -------------------------------
# HANDLE WINDOWS VS UNIX LINE ENDINGS
# -------------------------------
# The 'tr' command removes Windows-style carriage returns (\r),
# ensuring compatibility across platforms.
clean_file=$(mktemp)  # Create a temporary file for processing
tr -d '\r' < "$file" > "$clean_file"

# -------------------------------
# DATA PROCESSING BASED ON QUERY TYPE
# -------------------------------

# Convert input to uppercase
query_upper=$(echo "$query" | tr '[:lower:]' '[:upper:]')

# Check if the input is a valid **two-letter** state code (rejects 'NSW')
if [[ "$query_upper" =~ ^[A-Z]{3,}$ ]]; then
    echo "Error: US states are represented by two capital letters."
    exit 1
fi

case "$query" in

    "maxstate")
        # Find the state with the highest number of incidents.
        # The dataset should be tab-separated (TSV).
        read maxstate_count maxstate_state < <(tail -n +2 "$clean_file" | awk -F'\t' '{print $2}' | sort | uniq -c | sort -rn | head -n1 | awk '{print $1, $2}')
        
        # Display the result, ensuring a valid state was found.
        if [[ -n "$maxstate_state" ]]; then
            echo "State with the greatest number of incidents is: $maxstate_state with count $maxstate_count"
        else
            echo "Error: No data found."
        fi
        ;;

    "maxyear")
        # Find the year with the highest number of incidents.
        read maxyear_count maxyear_year < <(tail -n +2 "$clean_file" | awk -F'\t' '{print $8}' | sort | uniq -c | sort -rn | head -n1 | awk '{print $1, $2}')
        
        # Display the result, ensuring a valid year was found.
        if [[ -n "$maxyear_year" ]]; then
            echo "Year with the greatest number of incidents is: $maxyear_year with count $maxyear_count"
        else
            echo "Error: No data found."
        fi
        ;;

    [0-9]*)
        # If the query is a number (assumed to be a year),
        # find the state with the most incidents in that year.
        read count state < <(tail -n +2 "$clean_file" | awk -F'\t' -v year="$query" '$8 == year {print $2}' | sort | uniq -c | sort -rn | head -n1 | awk '{print $1, $2}')
        
        # Display the result, ensuring a valid match was found.
        if [[ -n "$state" ]]; then
            echo "State with the greatest number of incidents for $query is in $state with count $count"
        else
            echo "Error: No data found for year $query."
        fi
        ;;

    [A-Za-z][A-Za-z])
        # Convert input state to uppercase for case-insensitive matching
        state_upper=$(echo "$query" | tr '[:lower:]' '[:upper:]')
        
        # Find the year with the highest incidents for this state
        read count year < <(tail -n +2 "$clean_file" | awk -F'\t' -v state="$state_upper" '$2 == state {print $8}' | sort | uniq -c | sort -rn | head -n1 | awk '{print $1, $2}')
        
        # Display the result, ensuring a valid match was found.
        if [[ -n "$year" ]]; then
            echo "Year with the greatest number of incidents for $query is in $year with count $count"
        else
            echo "Error: No data found for state $query."
        fi
        ;;


    *)
        # If the command is not recognized, display an error.
        echo "Error: Invalid command. Use maxstate, maxyear, <year>, or <state>."
        exit 1
        ;;
esac


# Remove the temporary file to prevent clutter.
rm -f "$clean_file"
