#!/bin/bash
# Get monitor ID 0 according to hyprctl
hyprctl monitors | awk '/Monitor .*ID 0/{f=1} f && /model:/{print substr($0, index($0,$2)); f=0}'
