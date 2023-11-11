" Create the `b:undo_ftplugin` variable if it doesn't exist
call ftplugined#check_undo_ft()

" Change max length of a line to 99 for this buffer to match official guidelines
setlocal colorcolumn=99
let b:undo_ftplugin.='|setlocal colorcolumn<'
