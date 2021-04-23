# Show an error when a globbing expansion doesn't find any match
setopt nomatch
# List on ambiguous completion and Insert first match immediately
setopt autolist menucomplete
# Use pushd when cd-ing around
setopt autopushd pushdminus pushdsilent
# Use single quotes in string without the weird escape tricks
setopt rcquotes
# Single word commands can resume an existing job
setopt autoresume
# Those options aren't wanted
unsetopt beep extendedglob notify
