# shellcheck shell=bash
alias la='ls -lha'
alias l='ls'
alias cd..='cd ..'
alias ..='cd ..'
alias ç='sd'
export EDITOR=${EDITOR:-hx}
alias e=$EDITOR
alias sdw=sd
function checkpoint {
	git commit -m "checkpoint" "$@"
}

function reset_term {
	tput reset
	apply_colors
}
