## Overview
This project showcases advanced Bash scripting skills by automating data cleaning, processing, and analysis for cybersecurity breach records. It includes:
- **Extracting key insights** (e.g., most affected state/year).
- **Cleaning and preprocessing the dataset** (format dates, extract month/year).
- **Analyzing breach trends per month** and detecting unusual activity.

## Files & Scripts
1. `cyber_breaches.sh`: Extracts insights from the original dataset (worst state, worst year, incidents per state/year).
2. `preprocess.sh`: Cleans the dataset, extracts `Month` & `Year`, and standardizes date formats. |
3. `breaches_per_month.sh`: Analyzes breach trends per month and flags outliers from the processed dataset. |
4. `Cyber_Security_Breaches.tsv`: Raw data file containing breach records.
5. `Cyber_Security_Breaches_Processed.tsv`: Cleaned dataset created by `preprocess.sh`.

## How to Use
1️⃣ Granting Execution Permission (If Needed)
By default, if you download the scripts directly, they are already executable.
However, if you download them as a ZIP file and extract them, you may need to grant execution permission by running:
```bash
chmod +x cyber_breaches.sh preprocess.sh breaches_per_month.sh
```

2️⃣ Extract Key Insights
To analyze which state had the most breaches:
```bash
./cyber_breaches.sh Cyber_Security_Breaches.tsv maxstate
```
Example Output:
```
State with the greatest number of incidents is: CA with count 113
```

3️⃣ Preprocess Data (Extract Month & Year)
Before analyzing trends, preprocess the dataset to create a month and year column:
```bash
./preprocess.sh Cyber_Security_Breaches.tsv > Cyber_Security_Breaches_Processed.tsv
```

4️⃣ Analyze Breach Trends by Month
```bash
./breaches_per_month.sh Cyber_Security_Breaches_Processed.tsv
```
```
Example Output:
Month   Count   Flag
Jan     100     
Feb     93      
Mar     102     
Apr     71      
Sep     107     ++
```

## System Requirements
- Bash (Linux/macOS)
- awk, sort, and cut utilities
