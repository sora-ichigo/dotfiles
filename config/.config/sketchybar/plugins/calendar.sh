#!/usr/bin/env bash

sketchybar --set "$NAME" label="$(LC_TIME=en_US.UTF-8 date '+%a %d. %b  %H:%M')"
