" Create the `b:undo_ftplugin` variable if it doesn't exist
function! ftplugined#check_undo_ft()
    if !exists("b:undo_ftplugin")
        let b:undo_ftplugin=''
    endif
endfunction
