#!/bin/bash

# Threshold for CPU idle time
threshold=5

# Monitoring period in minutes (15 minutes)
monitoring_period=15

# This will create an infinite loop
while true; do

    # Initial sleep time of 2.5 hours
    sleep 9000s 

    # Check CPU idle time every minute for the next 15 minutes
    for ((i=0; i<$monitoring_period; i++)); do
        current_idle=$(sar -u 1 1 | tail -1 | awk '{print $8}')
        
        if (( $(echo "$current_idle < $threshold" | bc -l) )); then
            echo "CPU idle time is less than $threshold%, shutting down."
            sudo shutdown -h now
            exit 0
        fi
        sleep 60s
    done

    echo "CPU idle time was not less than $threshold% in the past 15 minutes."

done
