# shellcheck shell=bash
# Bootstrap shell init from modot once.
if [[ -z "${MODOT_SHELL_INIT_BOOTSTRAP:-}" ]] && command -v modot >/dev/null 2>&1; then
	MODOT_SHELL_INIT_BOOTSTRAP=1
	__ws_shell_init="$(modot utils shell init bash)" || __ws_shell_init=""
	if [[ -n "$__ws_shell_init" ]]; then
		eval "$__ws_shell_init"
		unset __ws_shell_init
	fi
	unset __ws_shell_init
fi
