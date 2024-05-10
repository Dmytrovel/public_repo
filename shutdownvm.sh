#!/bin/bash

log_file="/var/log/shutdown_script.log"

log_message() {
    local timestamp=$(date +"%Y-%m-%d %T")
    echo "[$timestamp] $1" >> "$log_file"
}

cpu_threshold=$3
dir_to_monitor="/home/$4"
sleep $1
shutdown_triggered=0

log_message "Script started. Initial sleep for $1 sec. Then CPU usage and directory $4 will be monitored every $2 sec."
log_message "Shutdown will be triggered if both conditions: CPU usage remains above $cpu_threshold% and changes detected in directory in the past $2 sec."

while true; do
    # CPU Monitoring
    log_message "- Checking CPU usage..."
    cpu_avg_idle=$(sar -u 1 $2 | grep -oP '(\d*\.\d*|\d*)$' | sort -n | head -n1) 

    # Directory Monitoring
    log_message "- Checking for changes in the directory..."
    change_detected=0
    
    if inotifywait -r -e modify,create,delete,move --timeout $2 $dir_to_monitor; then
        change_detected=1
        log_message "  - Changes detected in the directory."
    else
        log_message "  - No file changes detected in the directory for the last $2 sec."
    fi

    # Check if both CPU usage and Directory Change conditions are met to shutdown
    if (( $(echo "$cpu_avg_idle > (100 - $cpu_threshold)" | bc -l) )) && [ $change_detected -eq 1 ]; then
        log_message "Both conditions met. CPU usage has remained above $cpu_threshold% for the past $2 sec and changes detected in directory. Initiating shutdown procedure..."
        sudo shutdown -h now
        exit 0
    else
        log_message "Both conditions not met. Waiting for next cycle."
    fi

    sleep 1s
done
