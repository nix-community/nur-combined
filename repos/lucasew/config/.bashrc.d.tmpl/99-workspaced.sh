# shellcheck shell=bash
# This file is partially replaced by 15-workspaced-init.source.sh when using workspaced shell init
# The .source.sh generates completion code in parallel for faster startup

if command -v workspaced >/dev/null 2>&1; then
	# Start daemon if not already running
	(workspaced daemon --try &) &>/dev/null
fi
