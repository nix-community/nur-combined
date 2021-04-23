" Create the `b:undo_ftplugin` variable if it doesn't exist
call ftplugined#check_undo_ft()

" Use shfmt as ALE fixer for bash
let b:ale_fixers=[ 'shfmt' ]
let b:undo_ftplugin.='|unlet! b:ale_fixers'

" Indent with 4 spaces, simplify script, indent switch cases, use Bash variant
let b:ale_sh_shfmt_options='-i 4 -s -ci -ln bash'
let b:undo_ftplugin.='|unlet! b:ale_sh_shfmt_options'

" Use bash dialect explicitly, require explicit empty string test
let b:ale_sh_shellcheck_options='-s bash -o avoid-nullary-conditions'
let b:undo_ftplugin.='|unlet! b:ale_sh_shellcheck_options'
