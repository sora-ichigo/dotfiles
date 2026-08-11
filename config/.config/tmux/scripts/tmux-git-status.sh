#!/usr/bin/env bash
cd "$1" 2>/dev/null || { printf '%s' "--"; exit; }
branch=$(git symbolic-ref --short HEAD 2>/dev/null \
  || git rev-parse --short HEAD 2>/dev/null)
if [ -z "$branch" ]; then
  printf '%s' "--"
  exit
fi
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  printf '%s*' "$branch"
else
  printf '%s' "$branch"
fi
