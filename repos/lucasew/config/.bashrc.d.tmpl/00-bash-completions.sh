# shellcheck shell=bash
# The bash-completion *package* is not enough. Ubuntu comments the hook out of
# /etc/bash.bashrc; /etc/profile.d only runs in login shells. Interactive
# bashrc must source the framework so _init_completion / _filedir exist.

if [[ -n "${BASH_VERSION:-}" ]] && ! shopt -oq posix && [[ -z "${BASH_COMPLETION_VERSINFO:-}" ]]; then
	if [[ -r /usr/share/bash-completion/bash_completion ]]; then
		. /usr/share/bash-completion/bash_completion
	elif [[ -r /etc/bash_completion ]]; then
		. /etc/bash_completion
	elif [[ -r /opt/homebrew/etc/profile.d/bash_completion.sh ]]; then
		. /opt/homebrew/etc/profile.d/bash_completion.sh
	elif [[ -r /usr/local/etc/profile.d/bash_completion.sh ]]; then
		. /usr/local/etc/profile.d/bash_completion.sh
	fi
fi
