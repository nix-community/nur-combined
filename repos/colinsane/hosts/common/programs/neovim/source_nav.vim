function GoToHeader()
  let newfile = expand('%:r') . '.h'
  execute "e " . fnameescape(l:newfile)
endfunc
function GoToSource()
  let newfile = expand('%:r') . '.c'
  execute "e " . fnameescape(l:newfile)
endfunc
function ToggleHeaderSource()
  " If in abc.c file, open abc.h
  " If in abc.h, open abc.c
  let ext = expand('%:e')
  if ext =~ 'c'
    call GoToHeader()
  else
    call GoToSource()
  end
endfunc

" command H call ToggleHeaderSource()
" command C call ToggleHeaderSource()

nmap H :call ToggleHeaderSource()<CR>

" TODO: port to lua impl
" vim.api.nvim_set_keymap("n", "H", "", { callback=ToggleHeaderSource, desc = "cycle between .h <-> .c files" })
