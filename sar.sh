#!/bin/bash

# Threshold for CPU usage (Average CPU usage should be less than this value for 3 hours)
# threshold=5
threshold=$3

# Logfile path
log_file="/var/log/cpu_idel.log"


# Function to log timestamped messages
log_message() {
    local timestamp=$(date +"%Y-%m-%d %T")
    echo "[$timestamp] $1" >> "$log_file"
}

# Convert the threshold percentage to sar format
sar_threshold=$(echo "100 - $threshold" | bc)

# Initial sleep of 2.5 hours
# sleep 9000s
sleep $1

# Run indefinitely
while true; do
    # Get the average CPU idle time over the past 30 minutes
    # cpu_avg_idle=$(sar -u 30 1 | grep "Average" | awk '{print $NF}') # higher max cpu
    cpu_avg_idle=$(sar -u $2 1 | grep "Average" | awk '{print $NF}')

    if (( $(echo "$cpu_avg_idle > $sar_threshold" | bc -l) )); then
        log_message "Average CPU usage has remained below 5% for the past 30 minutes, shutting down..."
        sudo shutdown -h now
        exit 0
    fi

    log_message "Average CPU usage for the past 30 minutes was above 5%, starting a new cycle..."
    sleep 60s
done
