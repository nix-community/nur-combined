# History hook for workspaced

_workspaced_history_hook() {
	local exit_code=$?
	local cmd
	# Get last command from history
	cmd=$(HISTTIMEFORMAT='' history 1 | sed 's/^[ ]*[0-9]*[ ]*//')

	# Avoid recording the record command itself and empty commands
	if [[ -z "$cmd" || "$cmd" == "workspaced history record"* || "$cmd" == "workspaced utils history record"* ]]; then
		return
	fi

	# Send to daemon in background and detach completely to prevent job control messages
	(workspaced utils history record \
		--command "$cmd" \
		--cwd "$PWD" \
		--exit-code "$exit_code" \
		--timestamp "$(date +%s)" &) &>/dev/null
}

if [[ -n "$BASH_VERSION" && $- == *i* ]]; then
	if [[ "$PROMPT_COMMAND" != *"_workspaced_history_hook"* ]]; then
		PROMPT_COMMAND="_workspaced_history_hook${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
	fi
	# Bind Ctrl+R to history search. If cancelled, keep the current line.
	bind -x '"\C-r": "SELECTED=$(workspaced utils history search \"$READLINE_LINE\"); if [[ -n \"$SELECTED\" ]]; then READLINE_LINE=$SELECTED; READLINE_POINT=${#READLINE_LINE}; fi"'
fi
