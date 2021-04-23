" Always display the sign column to avoid moving the buffer all the time
let g:ale_sign_column_always=1

" Change the way ALE display messages
let g:ale_echo_msg_info_str='I'
let g:ale_echo_msg_warning_str='W'
let g:ale_echo_msg_error_str='E'

" The message displayed in the command line area
let g:ale_echo_msg_format='[%linter%][%severity%]%(code):% %s'

" The message displayed in the location list
let g:ale_loclist_msg_format='[%linter%]%(code):% %s'

" Don't lint every time I change the buffer
let g:ale_lint_on_text_changed=0
" Don't lint on leaving insert mode
let g:ale_lint_on_insert_leave=0
" Don't lint on entering a buffer
let g:ale_lint_on_enter=0
" Do lint on save
let g:ale_lint_on_save=1
" Lint on changing the filetype
let g:ale_lint_on_filetype_changed=1
