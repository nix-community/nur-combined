" Create the `b:undo_ftplugin` variable if it doesn't exist
call ftplugined#check_undo_ft()

" Don't highlight trailing whitespace in fugitive windows
let b:better_whitespace_enabled=0
let b:undo_ftplugin.='|unlet! b:better_whitespace_enabled'
