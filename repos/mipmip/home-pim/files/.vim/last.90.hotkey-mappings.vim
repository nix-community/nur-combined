" Learn VIM hard way
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

function! SearchUnderCursor()
  exec ":Ag " . expand('<cword>')
endfunction

function! Saveas()
  let cursor_placement = repeat("\<Left>",len(expand("%:e"))+4)
  return ":saveas ". expand("%:r") . "_dup." .expand("%:e") . cursor_placement
endfunction

function! PandocMakePDF()
" exe ":AsyncRun /usr/local/bin/fred process_frontmatter_specials -d % | sed 's/\\\[\\\[.*\\\]\\\]//g' > /tmp/pandotemp.md && ~/.rbenv/shims/pandocomatic -b -i /tmp/pandotemp.md"
 exe ":AsyncRun fred process_frontmatter_specials -d % | sed 's/\\\[\\\[.*\\\]\\\]//g' > /tmp/pandotemp.md && cd ~/nixos/shells/pandocomatic && nix-shell --run 'bundle exec pandocomatic -b -i /tmp/pandotemp.md'"
endfunction

function! OpenPandocPDF()
 let filen = system("/usr/local/bin/fred echo doelbestand /tmp/pandotemp.md")
 let filen = substitute(filen, '"', "", "g")
 exe ':AsyncRun nautilus -s "'.filen.'"'
endfunction


call panelmanager#init()
call PMRegisterPanelView('left',   'nerdtree', 'NERDTree',       'NERDTreeClose')
call PMRegisterPanelView('left',       'voom', 'Voom markdown',       'Voomquit')
call PMRegisterPanelView('left',      'linny', 'LinnyMenuOpen', 'LinnyMenuClose')
call PMRegisterPanelView('bottom', 'quickfix', 'copen',                 'cclose')
call PMRegisterPanelView('right',   'minimap', 'Minimap',         'MinimapClose')
call PMRegisterPanelView('right',    'tagbar', 'Tagbar',           'TagbarClose')
call PMRegisterPanelView('right',     'mundo', 'MundoShow',          'MundoHide')

call hotpop#init()

call HotpopMap('nmap', '', '<leader>?', ':call HotpopShow()<CR>',             'Hotmap',        'Open this popup...')
call HotpopMap('map',  '', '<leader>1', ":call PMToggleView('nerdtree')<CR>", 'Left Panels',   'Toggle NERDTree panel')
call HotpopMap('map',  '', '<leader>2', ":call PMToggleView('voom')<CR>",     'Left Panels',   'Toggle VooM panel')
call HotpopMap('map',  '', '<leader>3', ":call PMToggleView('linny')<CR>",    'Left Panels',   'Toggle Linny panel')
call HotpopMap('map',  '', '<leader>5', ":call PMToggleView('quickfix')<CR>", 'Bottom Panels', 'Toggle QuickFix panel')
call HotpopMap('map',  '', '<leader>8', ":call PMToggleView('mundo')<CR>",    'Right Panels',  'Toggle Mundo panel')
call HotpopMap('map',  '', '<leader>9', ":call PMToggleView('tagbar')<CR>",   'Right Panels',  'Toggle Tagbar panel')
call HotpopMap('map',  '', '<leader>0', ":call PMToggleView('minimap')<CR>",  'Right Panels',  'Toggle Minimap panel')



call HotpopMap('nmap',     '',         ',fp',        ':let @" = expand("%:p")<CR>',         'File',    'Place complete path of current file in register')
call HotpopMap('nnoremap', '<expr>',   '<leader>sa', 'Saveas()',                            'File',    'Save current file as...')
call HotpopMap('nmap',     '',         ',vc',        ':call VimInNerdTree()<CR>',           'File',    'Open Vim configfiles in NERDTree')
call HotpopMap('nmap',     '',         ',vr',        ':source ~/.vim/vimrc<CR>',            'File',    'Reload vim configuration ')
call HotpopMap('nmap',     '',         ',b',         ':silent w<CR> :RunInBlender<CR><CR>', 'Blender', 'Run current script in Blender with listener')
call HotpopMap('nmap',     '',         ',bk',        ':!killall -9 blender<CR>',            'Blender', 'Killall blender procs')
call HotpopMap('map',      '',         '<leader>d',  ':set background=dark<cr>',            "Colors",  "Change to dark background")
call HotpopMap('map',      '',         '<leader>l',  ':set background=light<cr>',           "Colors",  "Change to light background")
call HotpopMap('map',      '',         '<leader>b',  ':Buffers<cr>',                        'FZF',     'FZF with open buffers')
call HotpopMap('map',      '',         '<leader>f',  ':Files<cr>',                          'FZF',     'FZF with files in current directory')
call HotpopMap('map',      '',         '<leader>w',  ':silent FixWhitespace<cr>',           'Format',    'Fix all whitespace')
call HotpopMap('nnoremap', '',         '<Leader>gc', ':Gcommit<CR>',                        'Git',     'Git commit')
call HotpopMap('nnoremap', '',         '<Leader>gs', ':Gstatus<CR>',                        'Git',     'Git status')
call HotpopMap('nnoremap', '',         '<Leader>gd', ':Gdiff<CR>',                          'Git',     'Git diff')
call HotpopMap('nnoremap', '',         '<Leader>gb', ':Gblame<CR>',                         'Git',     'Git blame')
call HotpopMap('nnoremap', '',         '<Leader>gp', ':Git push<CR>',                       'Git',     'Git push')
call HotpopMap('map',      '<silent>', ',f',         ':!open "%:p:h"<CR><CR>',              'File',    'Open current file with OS default application')
call HotpopMap('map',      '<silent>', ',o',         ':OIFM<CR>',                           'File',    'Show current file in Filemanager')
call HotpopMap('map',      '',         '<leader>r',  ':silent redraw!<cr>',                 'Misc',    'Redraw screen')
call HotpopMap('map',      '',         '<leader>tc', ':tabclose<cr>',                       'Tabs',    'close current tab')
call HotpopMap('nnoremap', '',         'td',         ':tabclose<CR>',                       'Tabs',    'Close tab')
call HotpopMap('nnoremap', '',         'tl',         ':tabnext<CR>',                        'Tabs',    'Next tab')
call HotpopMap('nnoremap', '',         'th',         ':tabprev<CR>',                        'Tabs',    'Previous tab')
call HotpopMap('nnoremap', '',         'tn',         ':tabnew<CR>',                         'Tabs',    'New tab')

call HotpopMap('nmap',    '', '\/',                             ':Ag ', 'SilverSearch', 'Silver Search in current directory')
call HotpopMap('noremap', '', '<c-]>', ':call SearchUnderCursor()<CR>', 'SilverSearch',     'SilverSearch word under cursor')

call HotpopMap('nnoremap', '<silent>', '<Leader>=', ' :exe "vertical resize " . (winwidth(0) * 16/15)<CR>', 'Resize',  'Make window wider')
call HotpopMap('nnoremap', '<silent>', '<Leader>-', ' :exe "vertical resize " . (winwidth(0) * 14/15)<CR>', 'Resize',  'Make window smaller')
call HotpopMap('xmap',     '',         'ga',        '<Plug>(EasyAlign)',                                    'Align',   'Start interactive EasyAlign in visual mode (e.g. vipga)')
call HotpopMap('nmap',     '',         'ga',        '<Plug>(EasyAlign)',                                    'Align',   'Start interactive EasyAlign for a motion/text object (e.g. gaip)')
call HotpopMap('nmap',     '',         '\g',        ':Goyo<CR>',                                            'Writing', 'Toggle Goyo')
call HotpopMap('nmap',     '',         '\jf',       ':%!jq '.'<CR>',                                        'Format',  'Format JSON')
call HotpopMap('nmap',     '',         '\s',        ':call ToggleSpell()<CR>',                              'Writing', 'Toggle Spellcheck')
call HotpopMap('nmap',     '',         '\c',        ':RainbowLevelsToggle<CR>',                             'Colors',  'Toggle RainbowLevels')
call HotpopMap('nmap',     '',         ',mt',       ':call PandocMakePDF()<CR>',                            'Pandoc',  'Create PDF from Markdown file')
call HotpopMap('nmap',     '',         ',mo',       ':call OpenPandocPDF()<CR>',                            'Pandoc',  'Open last created PDF')
call HotpopMap('nmap',     '',         ',mv',       ':AsyncRun -silent showdown -B %<CR>',                  'Pandoc',  'Open Markdown in viewer')

call HotpopMap('map','',',,', ':call panelmanager#PMPrepareToggleView("nerdtree")<cr>:NERDTreeFind<cr>:call panelmanager#PMSetCurrentViewForIdentifier("nerdtree")<cr>',"File", "Open directory of current file in NERDTree")

call HotpopMap('map',      '<silent>', ',w',    ':call linny#FilenameToWordToUnamedRegister()<CR>',         'Linny', 'Put Linny Link of filename in register')
call HotpopMap('inoremap', '',         '<C-k>', '<C-R>=linny#browse_taxonomies()<CR>',                      'Linny', 'Browse through Taxonomies')
call HotpopMap('nmap',     '',         '<C-k>', ':startinsert<CR> <C-R>=linny#browse_taxonomies()<CR>',     'Linny', 'Browse through Taxonomies')
call HotpopMap('inoremap', '',         '<C-l>', '<C-R>=linny#browse_taxonomy_terms()<CR>',                  'Linny', 'Browse through Terms')
call HotpopMap('nmap',     '',         '<C-l>', ':startinsert<CR> <C-R>=linny#browse_taxonomy_terms()<CR>', 'Linny', 'Browse through Terms')
call HotpopMap('nmap',     '',         ';/',    ':LinnyGrep ',                                              'Linny', 'Search in Linny Docs')

"autocmd FileType markdown nnoremap ,i :call MDToolsImagePreview() <CR>
