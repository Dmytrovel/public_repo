#!/bin/bash

# Specify the directory you want to monitor
dir_to_monitor="/home/$0"

# How long to initially wait (in seconds)
initial_wait_seconds= 700 # 7200  # This is equivalent to 2 hours

# How long to wait with no changes (in seconds)
max_wait_seconds=120 # 900  # This is equivalent to 15 minutes

# Threshold for load average 
threshold=0.03

# Monitoring period in minutes (15 minutes)
monitoring_period=15

# Initial sleep
sleep $initial_wait_seconds

# This will create an infinite loop
while true; do
    change_detected=0

    # Check load average and if changes occurred in the directory
    for ((i=0; i<$monitoring_period; i++)); do
        load_avg=$(uptime | awk -F'load average: ' '{ print $2 }' | cut -d, -f1)
        inotifywait -r -e modify,create,delete,move --timeout 60 $dir_to_monitor && change_detected=1

        if (( $(echo "$load_avg < $threshold" | bc -l) )); then
            echo "Load average is less than $threshold, shutting down."
            sudo shutdown -h now
            exit 0
        elif [ $change_detected -eq 0 ]; then
            echo "No changes detected within the past minute, shutting down..."
            sudo shutdown -h now
            exit 0
        fi
        sleep 60s
    done

    echo "Neither load average dropped below the threshold nor absence of changes in the past 15 minutes detected."
done
