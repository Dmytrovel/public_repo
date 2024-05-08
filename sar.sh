#!/bin/bash

# Threshold for CPU usage (Average CPU usage should be less than this value for 3 hours)
threshold=5

# Logfile path
log_file="/var/log/cpu_idel.log"

# Function to log timestamped messages
log_message() {
    local timestamp=$(date +"%Y-%m-%d %T")
    echo "[$timestamp] $1" >> "$log_file"
}

# Conver threshold percentage to sar format
sar_threshold=$(echo "100 - $threshold" | bc)

while true; do
    cpu_avg_idle=$(sar -u $((3*60)) | grep "Average" | awk '{print $NF}')

    if (( $(echo "$cpu_avg_idle > $sar_threshold" | bc -l) )); then
        log_message "Average CPU usage has remained below 5% for the past 3 hours, shutting down..."
        sudo shutdown -h now
        exit 0
    fi
  
    log_message "Average CPU usage for the past 3 hours was above 5%, starting a new cycle..."
done
