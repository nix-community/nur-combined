" Create the `b:undo_ftplugin` variable if it doesn't exist
call ftplugined#check_undo_ft()

" Add comment format
setlocal comments=b://,s1:/*,mb:*,ex:*/
setlocal commentstring=//\ %s
let b:undo_ftplugin.='|setlocal comments< commentstring<'
