" Create the `b:undo_ftplugin` variable if it doesn't exist
call ftplugined#check_undo_ft()

" Change max length of a line to 88 for this buffer to match black's settings
setlocal colorcolumn=88
let b:undo_ftplugin.='|setlocal colorcolumn<'
