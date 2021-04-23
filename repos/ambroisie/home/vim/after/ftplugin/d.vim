" Create the `b:undo_ftplugin` variable if it doesn't exist
call ftplugined#check_undo_ft()

" Use my desired ALE fixer for D
let b:ale_fixers=[ 'dfmt' ]
let b:undo_ftplugin.='|unlet! b:ale_fixers'
