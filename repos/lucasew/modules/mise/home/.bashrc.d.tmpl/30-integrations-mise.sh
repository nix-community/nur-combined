# shellcheck shell=bash
# Mise via workspaced (home lazy tool). Prefer ~/.local/bin/mise from this module.

_mise_shims_dir="$HOME/.local/share/mise/shims"
_clean_path=":$PATH:"
_clean_path="${_clean_path//:$_mise_shims_dir:/:}"
_clean_path="${_clean_path#:}"
_clean_path="${_clean_path%:}"
export PATH="${_clean_path}"
unset _mise_shims_dir _clean_path

# Ensure module wrapper wins over a broken fixed path or stale activate hook.
if [[ -x "$HOME/.local/bin/mise" ]]; then
	export PATH="$HOME/.local/bin${PATH:+:$PATH}"
fi

if command -v mise >/dev/null 2>&1; then
	__ws_mise_activate="$(mise activate bash 2>/dev/null)" || __ws_mise_activate=""
	if [[ -n "${__ws_mise_activate}" ]]; then
		eval "${__ws_mise_activate}" 2>/dev/null
	fi
	unset __ws_mise_activate
fi

export MISE_ALL_COMPILE=false

# Termux: mise activate defines a function that shadows the binary.
if [[ -n "${TERMUX_VERSION:-}${ANDROID_ROOT:-}" ]] && command -v mise >/dev/null 2>&1; then
	unset -f mise 2>/dev/null || true
fi
