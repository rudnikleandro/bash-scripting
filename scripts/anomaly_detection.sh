#!/bin/bash
# Comprehensive Log Sweep in /var/log

LOG_DIR="/var/log"                   
OUTPUT_REPORT="log_sweep_report.txt" 
SUSPICIOUS_KEYWORDS=("failed" "denied" "invalid" "unauthorized" "root" "sudo") 
GEOIP_API="http://ip-api.com/json"   

touch "$OUTPUT_REPORT"

check_ip_geolocation() {
  local ip=$1
  curl -s "$GEOIP_API/$ip" | jq '.country, .regionName, .city'
}

scan_file() {
  local file=$1
  echo "Scanning file: $file"

  grep -iE "$(IFS=\|; echo "${SUSPICIOUS_KEYWORDS[*]}")" "$file" | while read -r line; do
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$TIMESTAMP - Found in $file: $line" >> "$OUTPUT_REPORT"

    ip=$(echo "$line" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b')
    if [ -n "$ip" ]; then
      echo "IP Detected: $ip" >> "$OUTPUT_REPORT"
      echo "Geolocation:" >> "$OUTPUT_REPORT"
      check_ip_geolocation "$ip" >> "$OUTPUT_REPORT"
      echo "--------------------------------------" >> "$OUTPUT_REPORT"
    fi
  done
}

scan_logs() {
  echo "Comprehensive Log Sweep Report - $(date)" > "$OUTPUT_REPORT"
  echo "Scanning logs in $LOG_DIR..." >> "$OUTPUT_REPORT"
  echo "--------------------------------------" >> "$OUTPUT_REPORT"

  sudo find "$LOG_DIR" -type f | while read -r log_file; do
    if [ -r "$log_file" ]; then
      scan_file "$log_file"
    else
      echo "$(date +"%Y-%m-%d %H:%M:%S") - Skipped unreadable file: $log_file" >> "$OUTPUT_REPORT"
    fi
  done

  echo "Log sweep complete. Report saved to $OUTPUT_REPORT."
}

# Main menu
echo "Log Sweep Script"
echo "1. Start log sweep"
echo "2. Exit"

read -p "Choose an option: " choice

case $choice in
  1)
    scan_logs
    ;;
  2)
    echo "Exiting script."
    ;;
  *)
    echo "Invalid option. Exiting."
    ;;
esac
