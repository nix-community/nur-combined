#!/bin/bash
set -eu
shopt -s nullglob

HOOK=$(basename $0)

case "$HOOK" in
	pre-push)
		STDIN=$(cat -)
		;;
	*)
		STDIN=
		;;
esac

if [[ -z "${GIT_DIR-}" ]]; then
	GIT_DIR="$(git rev-parse --git-dir)"
fi

HOOK_DIR="$GIT_DIR/hooks/$HOOK.d"
EXIT_CODE=0

if [[ -d "$HOOK_DIR" ]]; then
	for hook in "$HOOK_DIR"/*; do
		if [[ -x "$hook" ]]; then
			if [[ -n "$STDIN" ]]; then
				if echo $STDIN | "$hook" "$@"; then
					RETVAL=0
				else
					RETVAL=$?
				fi
			else
				if "$hook" "$@"; then
					RETVAL=0
				else
					RETVAL=$?
				fi
			fi

			if [[ "$RETVAL" != 0 && "$EXIT_CODE" = 0 ]]; then
				EXIT_CODE=$RETVAL
			fi
		fi
	done
fi

exit $EXIT_CODE
