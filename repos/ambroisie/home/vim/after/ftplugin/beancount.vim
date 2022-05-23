" Create the `b:undo_ftplugin` variable if it doesn't exist
call ftplugined#check_undo_ft()

" Use a small indentation value on beancount files
setlocal shiftwidth=2
let b:undo_ftplugin.='|setlocal shiftwidth<'

" Have automatic padding of transactions so that decimal is on 52nd column
let g:beancount_separator_col=52
