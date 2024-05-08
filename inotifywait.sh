#!/bin/bash

# Specify the directory path that you want to monitor
dir_to_monitor="/home/$0"

# Logfile paths
log_file="/var/log/directory.log"
changes_log_file="/var/log/directory_changes.log"

# Function to log timestamped messages
log_message() {
    local timestamp=$(date +"%Y-%m-%d %T")
    echo "[$timestamp] $1" >> "$log_file"
}

while true; do
    change_detected=0
    for ((i=0; i<30; i++)); do
        if inotifywait -r -e modify,create,delete,move --timeout 60 $dir_to_monitor; then
            change_detected=1
            echo "[$(date +"%Y-%m-%d %T")] Changes detected in $dir_to_monitor" >> "$changes_log_file"
        fi

        if [ $change_detected -eq 0 ]; then
            log_message "No file changes detected for last minute, shutting down..."
            sudo shutdown -h now
            exit 0
        fi

        sleep 60s
    done

    log_message "No shutdown triggered, starting a new cycle..."
done
