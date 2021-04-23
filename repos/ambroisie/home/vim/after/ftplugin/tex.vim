" Create the `b:undo_ftplugin` variable if it doesn't exist
call ftplugined#check_undo_ft()

" Use 2 spaces indentation inside TeX files
setlocal shiftwidth=2
let b:undo_ftplugin.='|setlocal shiftwidth<'
