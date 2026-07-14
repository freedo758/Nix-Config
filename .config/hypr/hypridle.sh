#!/usr/bin/env bash
if pgrep -x hypridle >/dev/null; then
icon=""   # example active icon
status="on"
else
icon=""   # example inactive icon
status="off"
fi
echo "$icon $status"
