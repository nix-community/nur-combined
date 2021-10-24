let g:MdConfMode = 'Programming_settings'

function! s:goyo_enter()

  setlocal showtabline=1
  set showtabline=1

  call g:Writer_settings_basic()
endfunction

function! s:goyo_leave()
  exe "call g:".g:MdConfMode."()"

endfunction

function! g:Writer_settings_basic()
  if has('macunix')
    set guifont=Inconsolata:h18
  else
    set guifont=Source\ Code\ Pro\ 10
  end
  set nonumber
  set linespace=7
  set textwidth=79
  set background=light
  colorscheme cleanroom

  highlight NonText ctermfg=white   " Match the tildes to your background
"  highlight! link FoldColumn Normal " Make it the background colour
  highlight FoldColumn guibg=white guifg=white
  highlight EndOfBuffer ctermfg=white ctermbg=white
  highlight! EndOfBuffer ctermbg=white ctermfg=white guibg=white guifg=white
endfunction

function! g:Writer_settings()
  call g:Writer_settings_basic()
  set noshowmode
  set noshowcmd
  set scrolloff=10
  set laststatus=0

  if (bufname("%") =~ "NERD_Tree_" || bufname("%") =~ "VOOM" || bufname("%") =~ "linnymenu")
    setlocal foldcolumn=0
  else
    setlocal foldcolumn=12
  endif

endfunction

function! g:Programming_settings()

  "  exe 'Voomquit'
  if (bufname("%") =~ "NERD_Tree_" || bufname("%") =~ "VOOM" || bufname("%") =~ "linnymenu")
    setlocal foldcolumn=0
  else
    setlocal foldcolumn=3
  endif

  set numberwidth=1
  "  set foldcolumn=6

  if has('macunix')
    set guifont=Menlo:h14
  else
    set guifont=Source\ Code\ Pro\ 10
  end

  execute 'colorscheme '. g:MainColor
"  set number
  set showtabline=1
  set linespace=2
endfunction


function! g:RestoreConfMode()

  let my_filetype = &filetype

"  if(my_filetype=='markdown' || bufname("%") =~ "NERD_Tree_")
    if g:MdConfMode == 'Programming_settings'
      call g:Programming_settings()
    else
      call g:Writer_settings()
    end

"  elseif(my_filetype !='')
"    call g:Programming_settings()
"  endif

endfunction

function! g:ToggleConfMode()

  let my_filetype = &filetype

  if(my_filetype=='markdown')

    if g:MdConfMode == 'Writer_settings'
      let g:MdConfMode = 'Programming_settings'
      call g:Programming_settings()
    else
      let g:MdConfMode = 'Writer_settings'
      call g:Writer_settings()
    endif

  else
    call g:Programming_settings()
  endif

endfunction


autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

autocmd BufEnter * call g:RestoreConfMode()
