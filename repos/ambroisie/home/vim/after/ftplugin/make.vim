" Create the `b:undo_ftplugin` variable if it doesn't exist
call ftplugined#check_undo_ft()

" Makefiles should use tabs to indent
setlocal noexpandtab
let b:undo_ftplugin.='|setlocal noexpandtab<'
