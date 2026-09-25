# shellcheck shell=bash
if [[ $- == *i* ]] && [[ -z "${MODOT_SHELL_INIT_BOOTSTRAP:-}" ]]; then
	printf '\033[1mUptime\033[0m: %s\n' "$(uptime)" || true
fi
