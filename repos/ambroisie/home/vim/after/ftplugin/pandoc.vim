" Create the `b:undo_ftplugin` variable if it doesn't exist
call ftplugined#check_undo_ft()

" Let ALE know that I want Markdown linters
let b:ale_linter_aliases=[ 'markdown' ]
let b:undo_ftplugin.='|unlet! b:ale_linter_aliases'

" Use a small indentation value on Pandoc files
setlocal shiftwidth=2
let b:undo_ftplugin.='|setlocal shiftwidth<'

" Use my usual text width
setlocal textwidth=80
let b:undo_ftplugin.='|setlocal textwidth<'
