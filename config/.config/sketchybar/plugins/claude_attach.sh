#!/usr/bin/env bash

sketchybar --set claude popup.drawing=off
wezterm start -- claude attach "$1" >/dev/null 2>&1 &
