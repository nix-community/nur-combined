" Create the `b:undo_ftplugin` variable if it doesn't exist
call ftplugined#check_undo_ft()

" Don't show Netrw in buffer list
setlocal bufhidden=delete
let b:undo_ftplugin='|setlocal bufhidden<'
