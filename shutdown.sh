#!/bin/bash

# Threshold for load average 
threshold=0.05 

# Monitoring period in minutes (15 minutes)
monitoring_period=15

# Initial sleep time of 2.5 hours
sleep 200s 

# This will create an infinite loop
while true; do

    # Check load average every minute for the next 15 minutes
    for ((i=0; i<$monitoring_period; i++)); do
        # Fetch the 1 minute load average using 'uptime'
        load_avg=$(uptime | awk -F'load average: ' '{ print $2 }' | cut -d, -f1)
        if (( $(echo "$load_avg > $threshold" | bc -l) )); then
            echo "Load average is more than $threshold, shutting down."
            sudo shutdown -h now
            exit 0
        fi
        sleep 60s
    done

    echo "Load average was not higher than $threshold in the past 15 minutes."

done
