" Create the `b:undo_ftplugin` variable if it doesn't exist
call ftplugined#check_undo_ft()

" Use my desired ALE fixers for python
let b:ale_fixers=[ 'black', 'isort' ]
let b:undo_ftplugin.='|unlet! b:ale_fixers'
" Use my desired ALE linters for python
let b:ale_linters=[ 'flake8', 'mypy', 'pylint', 'pyls' ]
let b:undo_ftplugin.='|unlet! b:ale_linters'

" Use pyls inside the python environment if needed
let b:ale_python_pyls_auto_pipenv=1
let b:undo_ftplugin.='|unlet! b:ale_python_pyls_auto_pipenv'

" Disable pycodestyle checks from pyls because I'm already using flake8
let b:ale_python_pyls_config={
  \     'pyls': {
  \         'plugins': {
  \             'pycodestyle': {
  \                 'enabled': v:false
  \             },
  \         },
  \     },
  \  }
let b:undo_ftplugin.='|unlet! b:ale_python_pyls_config'

" Don't use mypy to check for syntax errors
let b:ale_python_mypy_ignore_invalid_syntax=1
let b:undo_ftplugin.='|unlet! b:ale_python_mypy_ignore_invalid_syntax'
" Use mypy inside the python environment if needed
let b:ale_python_mypy_auto_pipenv=1
let b:undo_ftplugin.='|unlet! b:ale_python_mypy_auto_pipenv'

" Automatically format files when saving them
let b:ale_fix_on_save=1
let b:undo_ftplugin='|unlet! b:ale_lint_on_save'

" Change max length of a line to 88 for this buffer to match black's settings
setlocal colorcolumn=88
let b:undo_ftplugin.='|setlocal colorcolumn<'
