let g:scimCommand = 'sc-im'

let g:rooter_silent_chdir = 1

"-----------------------------------------------
let g:markdown_folding = 1

"-----------------------------------------------
let g:ycm_python_binary_path = '/usr/bin/python'

"-----------------------------------------------
let g:table_mode_corner='|'

"-----------------------------------------------
let g:jsx_ext_required = 0


"-----------------------------------------------
let g:syntastic_debug = 0

"-----------------------------------------------
let g:ycm_key_list_previous_completion=['<Up>']

"-----------------------------------------------
let g:UltiSnipsSnippetsDir = '~/.vim/UltiSnips'
let g:UltiSnipsExpandTrigger="<tab>"
"let g:UltiSnipsExpandTrigger="<c-tab>"
"let g:UltiSnipsListSnippets="<c-s-tab>"

"-----------------------------------------------
let g:arduino_serial_port = "/dev/cu.usbserial-1410"

"-----------------------------------------------
let g:netrw_home='~/.vim_temp'
let g:netrw_nogx = 1 " disable netrw's gx mapping.

"-----------------------------------------------
let g:goyo_width = 90
let g:goyo_height = "98%"

"-----------------------------------------------
let g:asyncrun_open = 8

nmap gx <Plug>(openbrowser-smart-search)
vmap gx <Plug>(openbrowser-smart-search)


vnoremap cc call <SID>SumSelectedText(visualmode())<CR>

let g:syntastic_mode_map = {
    \ "mode": "active",
    \ "passive_filetypes": ["html"] }

"let g:rufo_auto_formatting = 1

let g:indentLine_color_term = 37
let g:indentLine_bufTypeExclude = ['terminal', 'help', 'linny_menu', 'nofile' ]
let g:indentLine_fileTypeExclude = ['markdown', 'text']
let g:indentLine_char='┊'

"-----------------------------------------------
let g:mundo_width = 60
let g:mundo_preview_height = 40
let g:mundo_right = 1

"-----------------------------------------------
let g:slime_target = "tmux"
let g:slime_default_config = {"socket_name": "default", "target_pane": "%i"}
let g:slime_no_mappings = 1
