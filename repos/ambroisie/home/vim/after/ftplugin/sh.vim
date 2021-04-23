" Create the `b:undo_ftplugin` variable if it doesn't exist
call ftplugined#check_undo_ft()

" Use shfmt as ALE fixer for sh
let b:ale_fixers=[ 'shfmt' ]
let b:undo_ftplugin.='|unlet! b:ale_fixers'

" Indent with 4 spaces, simplify the code, indent switch cases, use POSIX
let b:ale_sh_shfmt_options='-i 4 -s -ci -ln posix'
let b:undo_ftplugin.='|unlet! b:ale_sh_shfmt_options'

" Require explicit empty string test
let b:ale_sh_shellcheck_options='-o avoid-nullary-conditions'
let b:undo_ftplugin.='|unlet! b:ale_sh_shellcheck_options'
