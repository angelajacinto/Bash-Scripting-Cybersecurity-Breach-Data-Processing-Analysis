#!/usr/bin/env bash

# Ensure an input file is provided
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <TSV data file>"
    exit 1
fi

# Ensure the file exists and is not empty
if [[ ! -s "$1" ]]; then
    echo "Error: File '$1' does not exist or is empty."
    exit 1
fi

# Create temporary file for processing
tmpfile=$(mktemp)

# Extract the Month column and count occurrences (assuming Month is in column 6)
tail -n +2 "$1" | awk -F'\t' '$6 ~ /^[0-9]+$/ && $6 >= 1 && $6 <= 12 {counts[$6]++} END {for (m in counts) print m, counts[m]}' > "$tmpfile"

# Calculate Median
median=$(awk '{a[i++]=$2} END {n=int(i/2); if (i%2) print a[n]; else print (a[n-1] + a[n]) / 2}' "$tmpfile")

# Compute Absolute Deviation
awk -v median="$median" '{deviation=$2 - median; if (deviation < 0) deviation=-deviation; print $1, $2, deviation}' "$tmpfile" > "$tmpfile.tmp" && mv "$tmpfile.tmp" "$tmpfile"

# Calculate Median Absolute Deviation (MAD)
mad=$(awk '{a[i++]=$3} END {n=int(i/2); if (i%2) print a[n]; else print (a[n-1] + a[n]) / 2}' "$tmpfile")

# Convert Month Numbers to Names & Flag Outliers
awk -v median="$median" -v mad="$mad" '
BEGIN { 
    split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", month, " "); 
    for (i=1; i<=12; i++) month_map[i] = month[i];
}
{
    monthIndex = int($1);
    if (monthIndex >= 1 && monthIndex <= 12) {
        monthName = month_map[monthIndex]; 
    } else {
        next; # Skip invalid months
    }

    if ($2 < median - mad) flag = "--"; 
    else if ($2 > median + mad) flag = "++"; 
    else flag = " "; 

    print monthName, $2, flag;
}' "$tmpfile" | sort -k1,1n | cut -f2- > "$tmpfile.tmp" && mv "$tmpfile.tmp" "$tmpfile"

# Print final results with headers
echo -e "Month\tCount\tFlag"
cat "$tmpfile"

# Cleanup
rm -f "$tmpfile"

