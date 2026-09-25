# shellcheck shell=bash
# This file is partially replaced by 15-modot-init.source.sh when using modot shell init
# The .source.sh generates completion code in parallel for faster startup

if command -v modot >/dev/null 2>&1; then
	# Start daemon if not already running
	(modot daemon --try &) &>/dev/null
fi
