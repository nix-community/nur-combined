#!/bin/bash
sleep 0.2
set -euxo pipefail

HYPRCTL_PATH="/bin/hyprctl"
JQ_PATH="/bin/jq"

active_id=$($HYPRCTL_PATH activeworkspace -j | $JQ_PATH .id)
$HYPRCTL_PATH workspaces -j | $JQ_PATH --argjson active_id "$active_id" 'sort_by(.id) | [.[] | {id: (.id | tostring), focused: (.id == $active_id)}]'