" Create the `b:undo_ftplugin` variable if it doesn't exist
call ftplugined#check_undo_ft()

" Use a small indentation value on Nix files
setlocal shiftwidth=2
let b:undo_ftplugin.='|setlocal shiftwidth<'
