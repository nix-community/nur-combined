# shellcheck shell=bash
# This file is partially replaced by 15-modot-init.source.sh when using modot shell init

# The daemon is opt-in: it would stay resident in every interactive shell just
# to speed up `modot utils history record`, and the hook in 50-modot-history.sh
# already writes history straight to the database without it.
# Set MODOT_DAEMON=1 to start it, or run `modot daemon` by hand when needed.
if command -v modot >/dev/null 2>&1 && [[ ${MODOT_DAEMON:-0} == 1 ]]; then
	(modot daemon --try &) &>/dev/null
fi
