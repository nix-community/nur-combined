#!/bin/bash
set -eu
set -o pipefail

I3_WORKSPACE="$1"
I3_OUTPUT="$2"

if [[ $I3_WORKSPACE == current ]]; then
	I3_WORKSPACE=$(i3-msg -t get_workspaces | jq -r '(.[] | select(.focused)).name')
fi

if [[ $I3_OUTPUT == current ]]; then
	I3_OUTPUT=$(i3-msg -t get_workspaces | jq -r '(.[] | select(.focused)).output')
fi

i3-msg -t command workspace "$I3_WORKSPACE"
i3-msg -t command move workspace to output "$I3_OUTPUT"
i3-msg -t command workspace "$I3_WORKSPACE"
