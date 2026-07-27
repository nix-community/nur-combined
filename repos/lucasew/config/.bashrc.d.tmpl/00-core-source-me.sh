# shellcheck shell=bash
# Bootstrap shell init from workspaced once.
if [[ -z "${WORKSPACED_SHELL_INIT_BOOTSTRAP:-}" ]] && command -v workspaced >/dev/null 2>&1; then
	WORKSPACED_SHELL_INIT_BOOTSTRAP=1
	__ws_shell_init="$(workspaced utils shell init bash)" || __ws_shell_init=""
	if [[ -n "$__ws_shell_init" ]]; then
		eval "$__ws_shell_init"
		unset __ws_shell_init
	fi
	unset __ws_shell_init
fi
