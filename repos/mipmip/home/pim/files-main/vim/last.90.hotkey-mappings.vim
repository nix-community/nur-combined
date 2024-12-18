" Learn VIM hard way
noremap <up> <nop>
noremap <down> <nop>
noremap <left> <nop>
noremap <right> <nop>

"xnoremap <leader>X :<C-U> call ChatGPTTranslateSelect(visualmode())<Cr>
function! ChatGPTTranslateSelect(mode)
    " call with visualmode() as the argument
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end]     = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if a:mode ==# 'v'
        " Must trim the end before the start, the beginning will shift left.
        let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
        let lines[0] = lines[0][column_start - 1:]
    elseif  a:mode ==# 'V'
        " Line mode no need to trim start or end
    elseif  a:mode == "\<c-v>"
        " Block mode, trim every line
        let new_lines = []
        let i = 0
        for line in lines
            let lines[i] = line[column_start - 1: column_end - (&selection == 'inclusive' ? 1 : 2)]
            let i = i + 1
        endfor
    else
        return ''
    endif

    call writefile(lines, "/tmp/modstext.txt")
    let trans = execute(':! export $(cat /tmp/openaiapikey | xargs) && cat /tmp/modstext.txt | mods "translate to english" > /tmp/trans.txt')
    call cursor(line_end, 1)
    call execute(":r /tmp/trans.txt")
    call execute(":redraw!")
endfunction

function! SearchUnderCursor()
  exec ":Ag " . expand('<cword>')
endfunction

function! Saveas()
  let cursor_placement = repeat("<leader><Left>",len(expand("%:e"))+4)
  return ":saveas ". expand("%:r") . "_dup." .expand("%:e") . cursor_placement
endfunction

function! PandocMakePDF()
 exe ":AsyncRun fred process_functions -d % | sed 's/\\\[\\\[.*\\\]\\\]//g' > /tmp/pandotemp.md && cd ~/nixos/shells/pandocomatic && nix develop --command bash -c " .'"'."'bundle exec pandocomatic -b -i /tmp/pandotemp.md'".'"'
endfunction

function! OpenPandocPDF()
 let filen = system("/usr/local/bin/fred echo doelbestand /tmp/pandotemp.md")
 let filen = substitute(filen, '"', "", "g")
 exe ':AsyncRun nautilus -s "'.filen.'"'
endfunction

function! OpenCurrentInNerdTree()
  call panelmanager#PMPrepareToggleView("nerdtree")
  exe ':NERDTreeFind'
  call panelmanager#PMSetCurrentViewForIdentifier("nerdtree")
endfunction

function! LinBrsTaxs()
  call linny#browse_taxonomies()
endfunction

function! LinBrsTerms()
  call linny#browse_taxonomy_terms()
endfunction

function! LinnyWordsToRegister()
  call linny#FilenameToWordToUnamedRegister()
endfunction

function! VResizeLess()
 exe "vertical resize " . (winwidth(0) * 14/15)
endfunction

function! VResizeMore()
 exe "vertical resize " . (winwidth(0) * 16/15)
endfunction

call panelmanager#init()
call PMRegisterPanelView('left',   'nerdtree', 'NERDTree',       'NERDTreeClose')
call PMRegisterPanelView('left',       'voom', 'Voom markdown',       'Voomquit')
call PMRegisterPanelView('left',      'linny', 'LinnyMenuOpen', 'LinnyMenuClose')
call PMRegisterPanelView('right',   'minimap', 'Minimap',         'MinimapClose')
call PMRegisterPanelView('right',    'tagbar', 'Tagbar',           'TagbarClose')
call PMRegisterPanelView('right',     'mundo', 'MundoShow',          'MundoHide')

call hotpop#init()

" PORTED TO NEOVIM
"call HotpopMap('map',      '',         ',,',         ':call OpenCurrentInNerdTree()<CR>',  'File',          'Open directory of current file in NERDTree')
call HotpopMap('map',      '',         ',,',         ':NnnExplorer %:p:h<CR>',             'File',          'Open directory of current file in NNN')
call HotpopMap('map',      '',         ',b',         ':Buffers<cr>',                       'FZF',           'FZF with open buffers')
call HotpopMap('map',      '',         ',f',         ':Files<cr>',                         'FZF',           'FZF with files in current directory')
call HotpopMap('nmap',     '',         '<leader>?',  ':call HotpopShow()<CR>',             'Hotmap',        'Open this popup...')
call HotpopMap('nmap',     '',         ',/',         ':Ag ',                               'FZF',           'Silver Search in current directory')

call HotpopMap('map',      '',         '<leader>w',  ':silent FixWhitespace<cr>',          'Format',        'Fix all whitespace')
call HotpopMap('noremap',  '',         '<c-]>',      ':call SearchUnderCursor()<CR>',      'FZF',           'SilverSearch word under cursor')

call HotpopMap('inoremap', '',         '<C-k>',      '<C-R>=linny#btx()<CR>',              'Linny',         'Browse through Taxonomies INS Mode')
call HotpopMap('nmap',     '',         '<C-k>',      ':start<CR> <C-R>=linny#btx()<CR>',   'Linny',         'Browse through Taxonomies')
call HotpopMap('inoremap', '',         '<C-l>',      '<C-R>=linny#btr()<CR>',              'Linny',         'Browse through Terms INS Mode')
call HotpopMap('nmap',     '',         '<C-l>',      ':start<CR> <C-R>=linny#btr()<CR>',   'Linny',         'Browse through Terms')

" REMAPS

call HotpopMap('map',      '',         '<leader>1',  ":call PMToggleView('nerdtree')<CR>", 'Left Panels',   'Toggle NERDTree panel')
call HotpopMap('map',      '',         '<leader>2',  ":call PMToggleView('voom')<CR>",     'Left Panels',   'Toggle VooM panel')
call HotpopMap('map',      '',         '<leader>3',  ":call PMToggleView('linny')<CR>",    'Left Panels',   'Toggle Linny panel')
call HotpopMap('map',      '',         '<leader>d',  ':set background=dark<cr>',           "Colors",        "Change to dark background")
call HotpopMap('map',      '',         '<leader>l',  ':set background=light<cr>',          "Colors",        "Change to light background")
call HotpopMap('nmap',     '',         '<leader>jf', ':%!jq '.'<CR>',                      'Format',        'Format JSON')
call HotpopMap('map',      '',         '<leader>tb', ':silent TableModeRealign<CR>',       'Writing',       'Markdown Table re-aling')
call HotpopMap('xmap',     '',         'ga',         '<Plug>(EasyAlign)',                  'Align',         'Interactive EasyAlign in VIS mode E.g. vipga')
call HotpopMap('nmap',     '',         'ga',         '<Plug>(EasyAlign)',                  'Align',         'Interactive EasyAlign for a motion/text object E.g. gaip')
call HotpopMap('map',      '<silent>', ',ff',        ':!open "%:p:h"<CR><CR>',             'File',          'Open current file with OS default application')
call HotpopMap('map',      '<silent>', ',o',         ':OIFM<CR>',                          'File',          'Show current file in Filemanager')
call HotpopMap('map',      '<silent>', ',m',         ':MIP<CR>',                           'File',          'Open current file in MIP')
call HotpopMap('nmap',     '',         ',s',         ':call ToggleSpell()<CR>',            'Writing',       'Toggle Spellcheck off/NL/EN')
call HotpopMap('nmap',     '',         ',mt',        ':call PandocMakePDF()<CR>',          'Writing',       'Create PDF from Markdown file')
call HotpopMap('nmap',     '',         ',mo',        ':call OpenPandocPDF()<CR>',          'Writing',       'Open last created PDF')
call HotpopMap('map',      '<silent>', ',w',         ':call LinnyWordsToRegister()<CR>',   'Linny',         'Put Linny Link of filename in register')

"DEFAULT MAPPINGS NO REMAPS
call HotpopMap('map',      '',         '<leader>sc', '',                                   'Writing',       'Open Markdown Table in SC-IM')
call HotpopMap('nmap',     '',         '^^ __ << >>','',                                   'Writing',       'VooM node movements')

call HotpopMap('map',      '',         'za',         '',                                   'FOLDS',         'Toggle fold under cursor')
call HotpopMap('map',      '',         'zA',         '',                                   'FOLDS',         'Toggle fold under cursor recursively')
call HotpopMap('map',      '',         'zR',         '',                                   'FOLDS',         'Open all folds')
call HotpopMap('map',      '',         'zM',         '',                                   'FOLDS',         'Close all folds')

call HotpopMap('xnoremap', '',         'X',         ':<C-U> call ChatGPTTranslateSelect(visualmode())<Cr>', 'Writing',         'Translate selected text to english (ChatGPT)')


" RARELY USED

call HotpopMap('map',      '',         '<leader>5',  ":cclose<CR>",                        'Bottom Panels', 'Toggle QuickFix panel')
call HotpopMap('map',      '',         '<leader>8',  ":call PMToggleView('mundo')<CR>",    'Right Panels',  'Toggle Mundo panel')
call HotpopMap('map',      '',         '<leader>9',  ":call PMToggleView('tagbar')<CR>",   'Right Panels',  'Toggle Tagbar panel')
call HotpopMap('map',      '',         '<leader>0',  ":call PMToggleView('minimap')<CR>",  'Right Panels',  'Toggle Minimap panel')
call HotpopMap('nmap',     '',         '<leader>c',  ':RainbowLevelsToggle<CR>',           'Colors',        'Toggle RainbowLevels')
call HotpopMap('nnoremap', '',         '<leader>gc', ':Gcommit<CR>',                       'Git',           'Git commit')
call HotpopMap('nnoremap', '',         '<leader>gs', ':Gstatus<CR>',                       'Git',           'Git status')
call HotpopMap('nnoremap', '',         '<leader>gd', ':Gdiff<CR>',                         'Git',           'Git diff')
call HotpopMap('nnoremap', '',         '<leader>gb', ':Gblame<CR>',                        'Git',           'Git blame')
call HotpopMap('nnoremap', '',         '<leader>gp', ':Git push<CR>',                      'Git',           'Git push')
call HotpopMap('nnoremap', '<expr>',   '<leader>sa', 'Saveas()',                           'File',          'Save current file as...')
call HotpopMap('map',      '',         '<leader>r',  ':silent redraw!<cr>',                'Misc',          'Redraw screen')
call HotpopMap('map',      '',         '<leader>tc', ':tabclose<cr>',                      'Tabs',          'close current tab')
call HotpopMap('nnoremap', '<silent>', '<leader>=',  ':call VResizeMore()<CR>',            'Resize',        'Make window wider')
call HotpopMap('nnoremap', '<silent>', '<leader>-',  ':call VResizeLess()<CR>',            'Resize',        'Make window smaller')
call HotpopMap('nmap',     '',         '<leader>g',  ':Goyo<CR>',                          'Writing',       'Toggle Goyo')
call HotpopMap('nnoremap', '',         'td',         ':tabclose<CR>',                      'Tabs',          'Close tab')
call HotpopMap('nnoremap', '',         'tl',         ':tabnext<CR>',                       'Tabs',          'Next tab')
call HotpopMap('nnoremap', '',         'th',         ':tabprev<CR>',                       'Tabs',          'Previous tab')
call HotpopMap('nnoremap', '',         'tn',         ':tabnew<CR>',                        'Tabs',          'New tab')
call HotpopMap('nmap',     '',         ',br',        ':silent w<CR> :RunInBlender<CR><CR>','Blender',       'Run current script in Blender with listener')
call HotpopMap('nmap',     '',         ',bk',        ':!killall -9 blender<CR>',           'Blender',       'Killall blender procs')
call HotpopMap('nmap',     '',         ',fp',        ':let @" = expand("%:p")<CR>',        'File',          'Place complete path of current file in register')
call HotpopMap('nmap',     '',         ',vc',        ':call VimInNerdTree()<CR>',          'File',          'Open Vim configfiles in NERDTree')
call HotpopMap('nmap',     '',         ',vr',        ':source ~/.vim/vimrc<CR>',           'File',          'Reload vim configuration ')

call HotpopMap('map',      '',         '<leader>tl', '',                                   'MKDX',          'Toggle List Item')
call HotpopMap('map',      '',         '<leader>t',  '',                                   'MKDX',          'Toggle Task')
call HotpopMap('map',      '',         '<leader>lt', '',                                   'MKDX',          'Toggle Task 2')
call HotpopMap('map',      '',         '<leader>-',  '',                                   'MKDX',          'Complete Task')
call HotpopMap('map',      '',         '<leader>=',  '',                                   'MKDX',          'Complete Task')
call HotpopMap('map',      '',         '<leader>[',  '',                                   'MKDX',          'Demote Header')
call HotpopMap('map',      '',         '<leader>]',  '',                                   'MKDX',          'Promote Header')
call HotpopMap('map',      '',         '<leader>ln', '',                                   'MKDX',          'Toggle Link')
call HotpopMap('map',      '',         '<leader>/',  '',                                   'MKDX',          'Toggle Italic')
call HotpopMap('map',      '',         '<leader>b',  '',                                   'MKDX',          'Toggle Bold')
call HotpopMap('map',      '',         '<leader>`',  '',                                   'MKDX',          'Inline Code')
call HotpopMap('map',      '',         '<leader>s',  '',                                   'MKDX',          'Strike Through')
call HotpopMap('map',      '',         '<leader>i',  '',                                   'MKDX',          'Generate TOC')
call HotpopMap('imap',     '',         '< <tab>',    '',                                   'MKDX',          'Create <kbd> from INS Mode')


