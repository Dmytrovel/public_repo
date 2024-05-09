#!/bin/bash

# Specify the directory path that you want to monitor
dir_to_monitor="/home/$1"

# Logfile paths
log_file="/var/log/directory.log"
changes_log_file="/var/log/directory_changes.log"

# Function to log timestamped messages
log_message() {
    local timestamp=$(date +"%Y-%m-%d %T")
    echo "[$timestamp] $1" >> "$log_file"
}

# Initial sleep of 2.5 hours
sleep 9000s

while true; do
    change_detected=0
    
    # Monitor for changes for one hour
    if inotifywait -r -e modify,create,delete,move --timeout 3600 $dir_to_monitor; then
        change_detected=1
        echo "[$(date +"%Y-%m-%d %T")] Changes detected in $dir_to_monitor" >> "$changes_log_file"
    fi

    # If no changes were detected within one hour, log and shut down
    if [ $change_detected -eq 0 ]; then
        log_message "No file changes detected for last hour, shutting down..."
        sudo shutdown -h now
        exit 0
    fi
done
