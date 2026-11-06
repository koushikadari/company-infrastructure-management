#!/bin/bash

# --- CONFIGURATION ---
# Set the maximum allowed disk usage percentage
THRESHOLD=80

# Notification email (Leave blank or comment out if not using mailutils)
ALERT_EMAIL="your_email@example.com"

# Log file path
LOG_FILE="/var/log/disk_usage.log"

# Ensure the log file exists and is writable
touch "$LOG_FILE" 2>/dev/null || LOG_FILE="./disk_usage.log"

echo "=== Disk Space Check: $(date) ===" >> "$LOG_FILE"

# --- MONITORING LOOP ---
# 1. df -H lists file systems in human-readable base-10
# 2. grep -vE excludes pseudo filesystems, memory disks, and headers
# 3. awk outputs the percentage and partition path
df -H | grep -vE '^Filesystem|tmpfs|cdrom|loop|udev' | awk '{ print $5 " " $1 }' | while read -r output; do
    
    # Extract the percentage number and filesystem path
    usage=$(echo "$output" | awk '{ print $1 }' | cut -d'%' -f1)
    partition=$(echo "$output" | awk '{ print $2 }')
    
    # Check if usage is greater than or equal to the threshold
    if [ "$usage" -ge "$THRESHOLD" ]; then
        alert_msg="ALERT: Partition $partition is at ${usage}% usage (Threshold: ${THRESHOLD}%)"
        
        # Log the alert
        echo "[WARNING] $alert_msg" >> "$LOG_FILE"
        echo "$alert_msg"
        
        # Send an email alert if configured
        if [ -n "$ALERT_EMAIL" ]; then
            echo -e "System Hostname: $(hostname)\n\n$alert_msg\n\nFull Status:\n$(df -h $partition)" | \
            mail -s "Critical Disk Space Warning on $(hostname)" "$ALERT_EMAIL"
        fi
    fi
done
