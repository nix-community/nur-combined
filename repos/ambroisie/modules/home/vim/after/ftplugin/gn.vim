" Create the `b:undo_ftplugin` variable if it doesn't exist
call ftplugined#check_undo_ft()

" Set comment string, as it seems that no official GN support exists upstream
setlocal commentstring=#\ %s
let b:undo_ftplugin.='|setlocal commentstring<'
