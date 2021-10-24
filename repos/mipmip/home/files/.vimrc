if has('python3')
endif

for f in split(glob('~/.vim/base*.vim'), '\n')
  echom f
  exe 'source' f
endfor

if has('gui_running')
  for f in split(glob('~/.vim/gui*.vim'), '\n')
    exe 'source' f
  endfor
else
  for f in split(glob('~/.vim/cli*.vim'), '\n')
    exe 'source' f
  endfor
endif

for f in split(glob('~/.vim/last*.vim'), '\n')
  exe 'source' f
endfor
