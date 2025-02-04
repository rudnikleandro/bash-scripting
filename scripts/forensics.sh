#!/bin/bash

OUT_DIR="/tmp/forensics_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUT_DIR"

if [ "$EUID" -ne 0 ]; then
    echo "Administrator permissions required!" 
    exit 1
fi

echo "Extracting system information..."
echo "Date and time: $(date)" > "$OUT_DIR/system_info.txt"
who -a >> "$OUT_DIR/system_info.txt"
uptime >> "$OUT_DIR/system_info.txt"
hostnamectl >> "$OUT_DIR/system_info.txt"
df -h >> "$OUT_DIR/disk_usage.txt"
free -m >> "$OUT_DIR/memory.txt"

echo "Extracting running processes..."
ps aux --forest > "$OUT_DIR/processes.txt"

echo "Extracting network connection data..."
ss -tulpan > "$OUT_DIR/network_connections.txt"

echo "Extracting user information..."
cat /etc/passwd > "$OUT_DIR/users.txt"
cat /etc/group > "$OUT_DIR/groups.txt"

echo "Extracting command history..."
cat /root/.bash_history > "$OUT_DIR/root_history.txt" 2>/dev/null
for user in $(ls /home/); do
    cat "/home/$user/.bash_history" > "$OUT_DIR/${user}_history.txt" 2>/dev/null
done

echo "Extracting recent file information..."
find / -type f -mtime -3 -exec ls -lah {} + 2>/dev/null > "$OUT_DIR/recent_files.txt"

echo "Checking for suspicious files..."
find / -type f -perm -4000 2>/dev/null > "$OUT_DIR/suid_files.txt"
find / -type f -name "*.sh" -o -name "*.py" -o -name "*.php" -o -name "*.exe" -o -name "*.bat" 2>/dev/null > "$OUT_DIR/suspicious_files.txt"

echo "Compiling information..."
tar -czf "$OUT_DIR.tar.gz" -C "/tmp" "$(basename $OUT_DIR)"
rm -rf "$OUT_DIR"

echo "Extraction complete! File saved at: $OUT_DIR.tar.gz"
