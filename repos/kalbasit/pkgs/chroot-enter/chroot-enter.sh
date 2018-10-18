#!/usr/bin/env bash

set -eo pipefail

mountPoint=/mnt

args=("$@")
for i in $(seq 0 $#); do
	case "${args[$i]}" in
		--root)
			mountPoint="$1"
	esac
done


if [[ -e $mountPoint/etc/NIXOS ]]; then
	exec nixos-enter "$@"
else
	exec os-enter "$@"
fi
