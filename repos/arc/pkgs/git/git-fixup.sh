#!/usr/bin/env bash
set -eu

REV=''${1-HEAD}

CMD=(-i)
if [[ $REV = TAIL ]]; then
	REV=$(git rev-list HEAD | tail -n1)
	CMD+=(--root)
else
	REV=$(git rev-parse "$REV")
	CMD+=("$REV~")
fi

git commit --fixup "$REV"
exec git rebase "${CMD[@]}"
