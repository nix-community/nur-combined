# shellcheck shell=bash
function loadDotfilesEnv {
	export NIX_PATH="$BASE_NIX_PATH"
}

export -f loadDotfilesEnv
