" Create the `b:undo_ftplugin` variable if it doesn't exist
call ftplugined#check_undo_ft()

" Enable spell checking on commit messages
setlocal spell
let b:undo_ftplugin.='|setlocal spell<'

" Change max length of a line to 72 for this buffer
setlocal colorcolumn=72
let b:undo_ftplugin.='|setlocal colorcolumn<'
