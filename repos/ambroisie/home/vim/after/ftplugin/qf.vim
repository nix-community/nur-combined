" Create the `b:undo_ftplugin` variable if it doesn't exist
call ftplugined#check_undo_ft()

" Use h/l to go to the previous/next non-empty quickfix or location list
nnoremap <silent> <buffer> h :call quickfixed#older()<CR>
let b:undo_ftplugin.='|nunmap <buffer> h'
nnoremap <silent> <buffer> l :call quickfixed#newer()<CR>
let b:undo_ftplugin.='|nunmap <buffer> l'
