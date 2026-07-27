# shellcheck shell=bash

# ch - chdir then run
function ch {
	if [ $# -lt 2 ]; then
		echo "usage: ch <dir> <command> [args...]" >&2
		return 1
	fi

	local dir="$1"
	shift

	(cd "$dir" && "$@")
}
