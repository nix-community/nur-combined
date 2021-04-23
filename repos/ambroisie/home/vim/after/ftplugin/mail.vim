" Create the `b:undo_ftplugin` variable if it doesn't exist
call ftplugined#check_undo_ft()

" Change max length of a line to 72 to follow the netiquette
setlocal colorcolumn=72
let b:undo_ftplugin.='|setlocal colorcolumn<'
