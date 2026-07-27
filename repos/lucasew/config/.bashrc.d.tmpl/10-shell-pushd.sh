# shellcheck shell=bash
function _conditional_pushd {
	while [ $# -gt 0 ]; do
		if [ -d "$1" ]; then
			pushd "$1" >/dev/null 2>&1
			return 0
		else
			shift
		fi
	done
	return 1
}


function nixpkgs {
	_conditional_pushd nixpkgs ~/nixpkgs ~/WORKSPACE/OPENSOURCE-contrib/nixpkgs
}

function gcd {
	_conditional_pushd "$(sd g root)/$*"
}

function rcd {
	selected_repo="$(find ~/WORKSPACE -maxdepth 4 -type d -name '.git' | fzf -q "$*")"
	if [[ -n $selected_repo ]]; then
		_conditional_pushd "$selected_repo/.."
	else
		echo no repo selected >&2
	fi
}

function repo_root {
	git rev-parse --show-toplevel
}

function dcd {
	local root
	root="$(repo_root)"
	if [[ -n "$root" ]]; then
		selected_dir="$(fzf --walker-root="$root" --walker=dir,follow,hidden -q "$*")"
		_conditional_pushd "$selected_dir"
	fi
}
