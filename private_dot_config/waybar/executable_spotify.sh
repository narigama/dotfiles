#!/bin/bash
set -euo pipefail

if [[ $(playerctl -p spotify status) == "Playing" ]]; then
  printf "$(playerctl -p spotify metadata -f '{{artist}} - {{title}}') \uf1bc "
else
  printf "... \uf1bc "
fi

