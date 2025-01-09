#!/bin/bash
# Network Analysis Script for Suspicious Activity

LOG_FILE="/var/log/tcpdump.log"  
LINES_TO_ANALYZE=100            
THRESHOLD=10                    

check_dependencies() {
  if ! command -v tcpdump &> /dev/null; then
    echo "tcpdump is not installed. Please install it using your package manager."
    exit 1
  fi
}

analyze_logs() {
  echo "Analyzing the last $LINES_TO_ANALYZE lines of $LOG_FILE..."

  if [ ! -f "$LOG_FILE" ]; then
    echo "Log file $LOG_FILE does not exist. Ensure tcpdump is running and logging traffic."
    exit 1
  fi

  # unusual ports
  echo -e "\n[1] Unusual Port Access:"
  grep -E "DPT=[0-9]{1,5}" "$LOG_FILE" | tail -n $LINES_TO_ANALYZE | \
    awk '{print $NF}' | grep -oP 'DPT=\K[0-9]+' | sort | uniq -c | sort -nr | \
    awk -v threshold=$THRESHOLD '$1 > threshold {print "Suspicious activity on port: " $2 ", Attempts: " $1}'

  # repeated failed connection attempts
  echo -e "\n[2] Repeated Failed Connections:"
  grep "Flags \[R\]" "$LOG_FILE" | tail -n $LINES_TO_ANALYZE | \
    awk '{print $3}' | sort | uniq -c | sort -nr | \
    awk -v threshold=$THRESHOLD '$1 > threshold {print "Source IP: " $2 ", Failed Attempts: " $1}'

  # high traffic from a single source
  echo -e "\n[3] High Traffic from a Single Source:"
  grep "IP " "$LOG_FILE" | tail -n $LINES_TO_ANALYZE | \
    awk '{print $3}' | cut -d'.' -f1-4 | sort | uniq -c | sort -nr | \
    awk -v threshold=$THRESHOLD '$1 > threshold {print "Source IP: " $2 ", Packets: " $1}'

  # port scans
  echo -e "\n[4] Potential Port Scans:"
  grep "Flags \[S\]" "$LOG_FILE" | tail -n $LINES_TO_ANALYZE | \
    awk '{print $3}' | cut -d'.' -f1-4 | sort | uniq -c | sort -nr | \
    awk -v threshold=$THRESHOLD '$1 > threshold {print "Possible scan from: " $2 ", SYN packets: " $1}'

  echo -e "\nAnalysis complete!"
}

check_dependencies

echo "Starting tcpdump log analysis..."
analyze_logs
