" Create the `b:undo_ftplugin` variable if it doesn't exist
call ftplugined#check_undo_ft()

" Use a small indentation value on Haskell files
setlocal shiftwidth=2
let b:undo_ftplugin.='|setlocal shiftwidth<'

" Use my desired ALE fixers for Haskell
let b:ale_fixers=[ 'brittany' ]
let b:undo_ftplugin.='|unlet! b:ale_fixers'

" Use stack-managed `hlint`
let b:ale_haskell_hlint_executable='stack'
let b:undo_ftplugin.='|unlet! b:ale_haskell_hlint_executable'

" Use stack-managed `brittany`
let b:ale_haskell_brittany_executable='stack'
let b:undo_ftplugin.='|unlet! b:ale_haskell_brittany_executable'

" Use dynamic libraries because of Arch linux, with default ALE options
let b:ale_haskell_ghc_options='--dynamic -fno-code -v0'
let b:undo_ftplugin.='|unlet! b:ale_haskell_ghc_options'

" Automatically format files when saving them
let b:ale_fix_on_save=1
let b:undo_ftplugin='|unlet! b:ale_lint_on_save'

" Change max length of a line to 100 for this buffer to match official guidelines
setlocal colorcolumn=100
let b:undo_ftplugin.='|setlocal colorcolumn<'
