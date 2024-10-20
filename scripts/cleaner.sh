#!/bin/bash
#Script to clean log with more than 2 weeks, temporary files, and cache.

# % progress
progress() {
    for ((i = 0; i <= 100; i += 5)); do
        sleep 0.1
        printf "\r%d%% completed" "$i"
    done
    echo -e "\nDone!"
}

# Temp files and cache
echo "Cleaning temporary files and clearing cache..."
sudo rm -rf /tmp/*
sudo rm -rf ~/.cache/*
progress

# Logs
echo "Deleting outdated log files..."
LOG_DIR="/var/log"
DAYS=30
sudo find "$LOG_DIR" -type f -name "*.log" -mtime +$DAYS -exec rm -f {} \;
progress

# Package cache
echo "Removing cached package files..."
if [ -f /etc/debian_version ]; then
    sudo apt-get clean
elif [ -f /etc/redhat-release ]; then
    sudo dnf clean all
fi
progress

# Trash
echo "Emptying the trash bin..."
sudo rm -rf ~/.local/share/Trash/*
progress

