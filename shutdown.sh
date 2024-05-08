#!/bin/bash

# Specify the directory you want to monitor
dir_to_monitor="/home/$0"

# Threshold for CPU usage, transformed into idle time (3.1% usage -> 96.9% idle)
threshold=96.9

# This will create an infinite loop
while true; do
    change_detected=0

    # Check load average as well as if changes occurred in the directory
    for ((i=0; i<30; i++)); do
        cpu_idle=$(sar -u 1 1 | tail -1 | awk '{print $8}')
        inotifywait -r -e modify,create,delete,move --timeout 60 $dir_to_monitor && change_detected=1

        # If CPU usage goes above 3.1%, break the loop and reset the cycle
        if (( $(echo "$cpu_idle < $threshold" | bc -l) )); then
            echo "CPU usage has gone above 3.1%, resetting the cycle."
            break
        fi

        sleep 60s
    done

    # Shut down the system if CPU usage never exceeded 3.1% AND no changes occurred in the directory
    if (( $(echo "$cpu_idle >= $threshold" | bc -l) )) && [ $change_detected -eq 0 ]; then
        echo "CPU usage remained below 3.1% and no file changes detected for half an hour, shutting down..."
        sudo shutdown -h now

        # Exit the script since the machine is going to be shut down
        exit 0
    fi

    echo "No shutdown triggered, starting a new cycle..."
done
