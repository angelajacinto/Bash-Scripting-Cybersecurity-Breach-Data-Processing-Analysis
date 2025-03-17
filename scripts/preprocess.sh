#!/usr/bin/env bash

# Ensure an input file is provided
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <TSV data file>"
    exit 1
fi

# Ensure the file exists and is not empty
if [[ ! -s $1 ]]; then
    echo "Error: File '$1' does not exist or is empty."
    exit 1
fi

# Create a temporary file
tmpfile=$(mktemp)

# Process the file
awk -F'\t' '
BEGIN { OFS="\t" }
NR == 1 { print $1, $2, $3, $4, $5, "Month", "Year"; next }
{
    # Remove any existing quotes
    gsub(/\"/, "", $1);
    gsub(/\"/, "", $5);

    # Extract first date (if multiple exist)
    split($4, d, "-|/");

    # Ensure two-digit months
    if (length(d[1]) == 1) d[1] = "0" d[1];

    # Ensure four-digit years
    if (length(d[3]) == 2) {
        if (d[3] > 23) d[3] = "19" d[3];
        else d[3] = "20" d[3];
    }

    # Print cleaned data with no quotes
    print $1, $2, $3, d[1] "/" d[2] "/" d[3], $5, d[1], d[3];
}' "$1" > "$tmpfile"

# Display results
cat "$tmpfile"

# Cleanup
rm -f "$tmpfile"
