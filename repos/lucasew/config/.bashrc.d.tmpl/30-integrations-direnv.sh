# shellcheck shell=bash
# Termux: leave direnv off the prompt. Run `eval "$(direnv hook bash)"` to opt in.
if [[ -z ${TERMUX_VERSION:-} ]] && command -v direnv >/dev/null 2>&1; then
	eval "$(direnv hook bash)"
fi
