function! MDToolsImagePreview()
  let imageURL = matchstr(getline("."), '\s*\[.*\](\zs.\+\ze)')
  let cmd = "~/go/bin/dotmatrix " . imageURL

  let image = system(cmd)
"  let imageList = systemlist(cmd)
  let image = substitute(image, '','','g')
  let image = substitute(image, '[?25l','','g')
  let image = substitute(image, '[?12l[?25h','','g')
  "    echo image
  let imageList = reverse(split(image, '\n'))

  call append(line('.'), '-->')
  for i in imageList
    call append(line('.'), i )
  endfor
  call append(line('.'), '<!--')

  "    if(image != "EOF")

endfunction
