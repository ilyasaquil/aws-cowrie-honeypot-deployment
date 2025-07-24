#!/bin/bash

# Cowrie Honeypot Monitoring Script
# Author: Aquil Ilyas
# Description: Monitors Cowrie logs, sends email alerts, and uploads data to S3

# Configuration
LOG_FILE="/home/admin/cowrie/var/log/cowrie/cowrie.log"
EMAIL="aquil.ilyas1@gmail.com"
S3_BUCKET="honeypot-logs-20250503223051"

# Temporary variables to store session data
SESSION_ID=""
USERNAME=""
PASSWORD=""
COMMANDS=()
ATTACKER_IP=""
CITY=""
COUNTRY=""

# Function to send email with login details
send_login_email() {
    local username="$1"
    local password="$2"
    EMAIL_CONTENT="Username: $username\nPassword: $password\nAttacker IP: $ATTACKER_IP\nLocation: $CITY, $COUNTRY"
    echo -e "$EMAIL_CONTENT" | mail -s "Cowrie Attack - Login Credentials" "$EMAIL"
}

# Function to send email with collected commands after the session ends
send_commands_email() {
    local username="$1"
    local password="$2"
    local commands="$3"
    EMAIL_CONTENT="Username: $username\nPassword: $password\nAttacker IP: $ATTACKER_IP\nLocation: $CITY, $COUNTRY\nCommands:\n$commands"
    echo -e "$EMAIL_CONTENT" | mail -s "Cowrie Attack - Executed Commands" "$EMAIL"
}

# Function to save session data to S3
save_to_s3() {
    local commands="$1"
    local file_name="cowrie-session-${SESSION_ID}.json"
    
    echo "{
    \"session_id\": \"$SESSION_ID\",
    \"ip\": \"$ATTACKER_IP\",
    \"city\": \"$CITY\",
    \"country\": \"$COUNTRY\",
    \"username\": \"$USERNAME\",
    \"password\": \"$PASSWORD\",
    \"commands\": \"$commands\"
}" > "$file_name"

    aws s3 cp "$file_name" "s3://$S3_BUCKET/logs/" --quiet
    rm "$file_name"
}

# Monitor Cowrie log file
tail -n 0 -f "$LOG_FILE" | while read -r line
do
    # Extract IP address
    if [[ "$line" =~ New\ connection:\ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) ]]; then
        ATTACKER_IP="${BASH_REMATCH[1]}"
        SESSION_ID=$(date +%s)
        
        # Geo IP lookup
        GEO_INFO=$(curl -s http://ip-api.com/json/$ATTACKER_IP)
        CITY=$(echo "$GEO_INFO" | jq -r '.city')
        COUNTRY=$(echo "$GEO_INFO" | jq -r '.country')
    fi
    
    # Detect login attempt
    if [[ "$line" =~ login\ attempt\ \[b\'([^\']+)\'/b\'([^\']+)\' ]]; then
        USERNAME="${BASH_REMATCH[1]}"
        PASSWORD="${BASH_REMATCH[2]}"
        send_login_email "$USERNAME" "$PASSWORD"
        COMMANDS=()
    fi
    
    # Detect command execution
    if [[ "$line" =~ CMD:\ (.*) ]]; then
        CMD="${BASH_REMATCH[1]}"
        COMMANDS+=("$CMD")
    fi
    
    # End session on "exit"
    if [[ "$line" =~ "exit" ]]; then
        if [[ -n "$SESSION_ID" && -n "$USERNAME" && -n "$PASSWORD" && ${#COMMANDS[@]} -gt 0 ]]; then
            CMD_LIST=$(printf "%s\n" "${COMMANDS[@]}")
            send_commands_email "$USERNAME" "$PASSWORD" "$CMD_LIST"
            save_to_s3 "$CMD_LIST"
        fi
        
        # Reset session data
        SESSION_ID=""
        USERNAME=""
        PASSWORD=""
        COMMANDS=()
        ATTACKER_IP=""
        CITY=""
        COUNTRY=""
    fi
done