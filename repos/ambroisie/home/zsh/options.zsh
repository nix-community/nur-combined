# Show an error when a globbing expansion doesn't find any match
setopt nomatch
# List on ambiguous completion and Insert first match immediately
setopt auto_list menu_complete
# Use pushd when cd-ing around
setopt auto_pushd pushd_minus pushd_silent
# Use single quotes in string without the weird escape tricks
setopt rc_quotes
# Single word commands can resume an existing job
setopt auto_resume
# Show history expansion before running a command
setopt hist_verify
# Append commands to history as they are exectuted
setopt inc_append_history_time
# Remove useless whitespace from commands
setopt hist_reduce_blanks
# Those options aren't wanted
unsetopt beep extended_glob notify
