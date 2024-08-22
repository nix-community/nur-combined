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

" Spell Check
let b:myLang=0
let g:myLangList=["nospell","nl","en"]

function! ToggleSpell()
  if !exists( "b:myLang" )
    if &spell
      let b:myLang=index(g:myLangList, &spelllang)
    else
      let b:myLang=0
    endif
  endif

  let b:myLang=b:myLang+1

  if b:myLang>=len(g:myLangList)
    let b:myLang=0
  endif

  if b:myLang==0
    setlocal nospell
  else
    execute "setlocal spell spelllang=".get(g:myLangList, b:myLang)
  endif

  echo "spell checking language:" g:myLangList[b:myLang]
endfunction


call hotpop#init() "run this before other calls

call HotpopMap('inoremap', '',         '<C-k>',      '<C-R>=linny#btx()<CR>',              'Linny',         'Browse through Taxonomies INS Mode')
call HotpopMap('nmap',     '',         '<C-k>',      ':start<CR> <C-R>=linny#btx()<CR>',   'Linny',         'Browse through Taxonomies')
call HotpopMap('inoremap', '',         '<C-l>',      '<C-R>=linny#btr()<CR>',              'Linny',         'Browse through Terms INS Mode')
call HotpopMap('nmap',     '',         '<C-l>',      ':start<CR> <C-R>=linny#btr()<CR>',   'Linny',         'Browse through Terms')
call HotpopMap('map',      '<silent>', ',w',         ':LinnyWordToRegister<CR>',           'Linny',         'Put Linny Link of filename in register')

call HotpopMap('nmap',     '',         '<leader>?',  ':call HotpopShow()<CR>',             'Hotmap',        'Open this popup...')

call HotpopMap('xmap',     '',         'ga',         '<Plug>(EasyAlign)',                  'Align',         'Interactive EasyAlign in VIS mode E.g. vipga')
call HotpopMap('nmap',     '',         'ga',         '<Plug>(EasyAlign)',                  'Align',         'Interactive EasyAlign for a motion/text object E.g. gaip')

call HotpopMap('nmap',     '',         ',s',         ':call ToggleSpell()<CR>',            'Writing',       'Toggle Spellcheck off/NL/EN')

call HotpopMap('map',      '',         'za',         '',                                   'FOLDS',         'Toggle fold under cursor')
call HotpopMap('map',      '',         'zA',         '',                                   'FOLDS',         'Toggle fold under cursor recursively')
call HotpopMap('map',      '',         'zR',         '',                                   'FOLDS',         'Open all folds')
call HotpopMap('map',      '',         'zM',         '',                                   'FOLDS',         'Close all folds')

call HotpopMap('map',      '',         '<leader>5',  ":cclose<CR>",                        'Bottom Panels', 'Close QuickFix panel')


call HotpopMap('nnoremap', '',         '<leader>gc', ':Gcommit<CR>',                       'Git',           'Git commit')
call HotpopMap('nnoremap', '',         '<leader>gs', ':Gstatus<CR>',                       'Git',           'Git status')
call HotpopMap('nnoremap', '',         '<leader>gd', ':Gdiff<CR>',                         'Git',           'Git diff')
call HotpopMap('nnoremap', '',         '<leader>gb', ':Gblame<CR>',                        'Git',           'Git blame')
call HotpopMap('nnoremap', '',         '<leader>gp', ':Git push<CR>',                      'Git',           'Git push')

call HotpopMap('map',      '',         '<leader>r',  ':silent redraw!<cr>',                'Misc',          'Redraw screen')


call HotpopMap('map',      '<silent>', ',o',         ':OIFM<CR>',                          'File',          'Show current file in Filemanager')
call HotpopMap('map',      '<silent>', ',m',         ':MIP<CR>',                           'File',          'Open current file in MIP')
call HotpopMap('nmap',     '',         '<leader>jf', ':%!jq '.'<CR>',                      'Format',        'Format JSON')

call HotpopMap('nmap',     '',         ',fp',        ':let @* = expand("%:p")<CR>',        'File',          'Place complete path of current file in clipboard')
