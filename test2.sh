#!/bin/bash

# Function to check CPU usage and initiate shutdown if less than 5%
check_and_shutdown() {
    # Get current hour
    current_hour=$(date +%H)

    # Check if it's been 3 hours
    if [ "$current_hour" -ge 3 ]; then
        # Get CPU usage over the past 30 minutes
        cpu_usage=$(sar -u 1800 2 | awk '{sum+=$NF} END {print sum/2}')

        # Check if CPU usage is less than 5%
        if (( $(echo "$cpu_usage < 5" | bc -l) )); then
            # If CPU usage is less than 5%, initiate shutdown
            shutdown -h now
            echo "Shutting down due to low CPU usage"
        else
            echo "CPU idle remains enabled"
        fi
    else
        echo "Initial 3-hour period, CPU idle remains enabled"
    fi
}

# Call the function to check CPU usage and initiate shutdown if applicable
check_and_shutdown
