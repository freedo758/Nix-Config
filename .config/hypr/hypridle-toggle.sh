#!/usr/bin/env bash
# hypridle-toggle.sh — toggle hypridle (Hyprland idle daemon)

if pgrep -x hypridle &>/dev/null; then
  pkill hypridle
  notify-send -i system-suspend "Idle inhibitor" "DIACTIVATED — Screen won't lock"
else
  hypridle &
  disown
  notify-send -i system-shutdown "Idle inhibitor" "Activated — lock/sleep normally"
fi
