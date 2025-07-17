#!/bin/bash
set -euo pipefail

if [[ $(playerctl -p spotify status) == "Playing" ]]; then
  echo $(playerctl -p spotify metadata -f '{{artist}} - {{title}} ({{duration(position)}}/{{duration(mpris:length)}})')
else
  printf "OFF"
fi

