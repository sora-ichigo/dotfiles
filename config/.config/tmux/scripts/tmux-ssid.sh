#!/usr/bin/env bash
ssid=$(ipconfig getsummary en0 2>/dev/null \
  | awk -F ' SSID : ' '/ SSID : / {print $2; exit}')
[ -z "$ssid" ] && ssid="--"
printf '%s' "$ssid" | head -c 18
