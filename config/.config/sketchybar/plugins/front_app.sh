#!/usr/bin/env bash

[ "$SENDER" = "front_app_switched" ] || exit 0

source "$(command -v icon_map.sh)"
__icon_map "$INFO"
sketchybar --set "$NAME" icon="$icon_result" label="$INFO"
