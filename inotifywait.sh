#!/bin/bash

# Вказати шлях до каталогу, який ви хочете відстежувати
dir_to_monitor="/home/$0"

# Шляхи до файлів журналу
log_file="/var/log/directory.log"
changes_log_file="/var/log/directory_changes.log"

# Функція для реєстрації повідомлень з відміткою часу
log_message() {
    local timestamp=$(date +"%Y-%m-%d %T")
    echo "[$timestamp] $1" >> "$log_file"
}

while true; do
    change_detected=0

    # Очікування змін протягом однієї години
    if inotifywait -r -e modify,create,delete,move --timeout 3600 $dir_to_monitor; then
        change_detected=1
        echo "[$(date +"%Y-%m-%d %T")] Виявлені зміни в $dir_to_monitor" >> "$changes_log_file"
    fi

    # Якщо зміни не були виявлені протягом однієї години, виконати вимкнення системи
    if [ $change_detected -eq 0 ]; then
        log_message "Протягом останньої години змін не виявлено, вимкнення системи..."
        sudo shutdown -h now
        exit 0
    fi
done
