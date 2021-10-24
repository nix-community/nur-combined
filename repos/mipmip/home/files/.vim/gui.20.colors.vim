function! g:HourColor()
  if strftime("%H") >= 5 && strftime("%H") <= 23
    let g:MainColor = 'solarized'
    let g:MainBackground = 'light'
  else
    "let g:MainColor = 'petra'
    let g:MainColor = 'solarized'
    let g:MainBackground = 'dark'
  endif

  execute 'colorscheme '. g:MainColor
  execute 'set background='. g:MainBackground

  redraw
endfunction


call g:HourColor()

"let g:MainColor = 'solarized'
"let g:MainBackground = 'dark'
"execute 'set background=dark'
"
