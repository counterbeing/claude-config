#!/bin/bash

# ~/.claude/notify.sh
# Enhanced notification script for Claude Code with Pushover support

# Debug logging
echo "[$(date)] Script started" >>~/.claude/notifications.log

# Load configuration from .env file
ENV_FILE="$HOME/.claude/.env"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "[$(date)] Warning: $ENV_FILE not found. Please create it with PUSHOVER_TOKEN and PUSHOVER_USER." >> ~/.claude/notifications.log
    exit 1
fi

# Validate required variables
if [ -z "$PUSHOVER_TOKEN" ] || [ -z "$PUSHOVER_USER" ]; then
    echo "[$(date)] Error: PUSHOVER_TOKEN and PUSHOVER_USER must be set in $ENV_FILE" >> ~/.claude/notifications.log
    exit 1
fi

NOTIFICATION_METHOD="${NOTIFICATION_METHOD:-pushover}"

# Read JSON input from stdin
JSON_INPUT=""
if [ -t 0 ]; then
    # No stdin input
    JSON_INPUT="{}"
    echo "[$(date)] No stdin input detected" >>~/.claude/notifications.log
else
    # Read from stdin (macOS doesn't have timeout by default)
    JSON_INPUT=$(cat)
    echo "[$(date)] JSON received: ${JSON_INPUT:0:100}..." >>~/.claude/notifications.log
fi

# Parse JSON using jq if available, otherwise fallback to basic extraction
if command -v jq >/dev/null 2>&1; then
    SESSION_ID=$(echo "$JSON_INPUT" | jq -r '.session_id // empty')
    HOOK_EVENT=$(echo "$JSON_INPUT" | jq -r '.hook_event_name // empty')
    TRANSCRIPT_PATH=$(echo "$JSON_INPUT" | jq -r '.transcript_path // empty')
    MESSAGE=$(echo "$JSON_INPUT" | jq -r '.message // empty')
else
    # Basic grep-based extraction as fallback
    SESSION_ID=$(echo "$JSON_INPUT" | grep -o '"session_id":"[^"]*"' | cut -d'"' -f4 || echo "")
    HOOK_EVENT=$(echo "$JSON_INPUT" | grep -o '"hook_event_name":"[^"]*"' | cut -d'"' -f4 || echo "")
    TRANSCRIPT_PATH=$(echo "$JSON_INPUT" | grep -o '"transcript_path":"[^"]*"' | cut -d'"' -f4 || echo "")
fi

# Extract project name from working directory or transcript path
PROJECT_NAME=$(basename "$PWD" 2>/dev/null || echo "unknown")
if [ -n "$TRANSCRIPT_PATH" ] && [ "$PROJECT_NAME" = "unknown" ]; then
    PROJECT_NAME=$(basename "$(dirname "$TRANSCRIPT_PATH")" 2>/dev/null || echo "unknown")
fi

# Get current time
TIME=$(date +"%I:%M %p")

# Create notification message based on available info
if [ -n "$HOOK_EVENT" ] && [ "$HOOK_EVENT" != "Notification" ]; then
    TITLE="Claude Code 🤖"
    SUBTITLE="$HOOK_EVENT Event"
    MESSAGE_TEXT="Event: $HOOK_EVENT in $PROJECT_NAME ($TIME)"
    PUSHOVER_PRIORITY="0"
else
    TITLE="Claude Code 🤖"
    SUBTITLE="Ready for Input"
    MESSAGE_TEXT="Claude is ready for your next command in $PROJECT_NAME ($TIME)"
    PUSHOVER_PRIORITY="0"
fi

# Function to send terminal notification
send_terminal_notification() {
    echo "[$(date)] Attempting terminal notification" >>~/.claude/notifications.log
    if command -v terminal-notifier >/dev/null 2>&1; then
        terminal-notifier \
            -title "$TITLE" \
            -subtitle "$SUBTITLE" \
            -message "$MESSAGE_TEXT" \
            -sound "Glass" \
            -group "claude-code" 2>>~/.claude/notifications.log
        echo "[$(date)] Terminal notification sent" >>~/.claude/notifications.log
    else
        echo "[$(date)] terminal-notifier not available" >>~/.claude/notifications.log
    fi
}

# Function to send Pushover notification
send_pushover_notification() {
    if [ -n "$PUSHOVER_TOKEN" ] && [ -n "$PUSHOVER_USER" ]; then
        curl -s \
            --form-string "token=$PUSHOVER_TOKEN" \
            --form-string "user=$PUSHOVER_USER" \
            --form-string "title=$TITLE" \
            --form-string "message=$MESSAGE_TEXT" \
            --form-string "priority=$PUSHOVER_PRIORITY" \
            --form-string "sound=intermission" \
            https://api.pushover.net/1/messages.json >/dev/null
    else
        echo "Pushover credentials not configured"
    fi
}

# Send notifications based on method
case "$NOTIFICATION_METHOD" in
"terminal-notifier")
    send_terminal_notification
    ;;
"pushover")
    send_pushover_notification
    ;;
"both")
    send_terminal_notification
    send_pushover_notification
    ;;
*)
    echo "Unknown notification method: $NOTIFICATION_METHOD"
    send_terminal_notification
    ;;
esac

# Enhanced logging
echo "[$(date)] Hook: $HOOK_EVENT | Project: $PROJECT_NAME | Session: ${SESSION_ID:0:8}... | Method: $NOTIFICATION_METHOD" >>~/.claude/notifications.log
