" Create the `b:undo_ftplugin` variable if it doesn't exist
call ftplugined#check_undo_ft()

" Check tests too
let b:ale_rust_cargo_check_tests=1
let b:undo_ftplugin='|unlet! b:ale_rust_cargo_check_tests'

" Check examples too
let b:ale_rust_cargo_check_examples=1
let b:undo_ftplugin='|unlet! b:ale_rust_cargo_check_examples'

" Use clippy if it's available instead of just cargo check
let b:ale_rust_cargo_use_clippy=executable('cargo-clippy')
let b:undo_ftplugin='|unlet! b:ale_rust_cargo_use_clippy'

" Use rust-analyzer instead of RLS as a linter
let b:ale_linters=[ 'cargo', 'analyzer' ]
let b:undo_ftplugin='|unlet! b:ale_linters'


" Use rustfmt as ALE fixer for rust
let b:ale_fixers=[ 'rustfmt' ]
let b:undo_ftplugin.='|unlet! b:ale_fixers'

" Automatically format files when saving them
let b:ale_fix_on_save=1
let b:undo_ftplugin='|unlet! b:ale_lint_on_save'

" Change max length of a line to 99 for this buffer to match official guidelines
setlocal colorcolumn=99
let b:undo_ftplugin.='|setlocal colorcolumn<'
