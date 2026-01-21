#!/bin/bash

# ~/.claude/stop-notification.sh
# Simple sound notification when Claude stops responding

# Play a simple system beep
afplay /System/Library/Sounds/Pop.aiff

# Log the stop event
echo "[$(date)] Claude stopped responding" >>~/.claude/stop-notifications.log
