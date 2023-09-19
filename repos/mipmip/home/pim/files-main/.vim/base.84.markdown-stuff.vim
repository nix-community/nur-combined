function! CheckNew()
    let l:line=getline('.')
    "let l:curs=winsaveview()
    if l:line=~?'\s*-\s*\[\s*\].*'
    elseif l:line=~?'\s*-\s*\[x\].*'
    elseif l:line=~?'\s*-\s.*'
    else
        s/^/-\ [ ]\ /
    endif
    exe "norm! $"
    "call winrestview(l:curs)
endfunction

function! Check()
    let l:line=getline('.')
    let l:curs=winsaveview()
    if l:line=~?'\s*-\s*\[\s*\].*'
        s/\[\s*\]/[x]/
    elseif l:line=~?'\s*-\s*\[x\].*'
        s/-\ \[x\]\ /-\ /
    elseif l:line=~?'\s*-\s.*'
        s/\-\ /-\ [ ]\ /
    else
        s/^/-\ /
    endif
    call winrestview(l:curs)
endfunction

autocmd FileType markdown nnoremap <silent> _ :call CheckNew()<CR>
autocmd FileType markdown nnoremap <silent> - :call Check()<CR>
autocmd FileType markdown vnoremap <silent> - :call Check()<CR>
autocmd FileType markdown setlocal conceallevel=2

nnoremap <silent> <leader>xz :s/^\s*\(-<space>\\|\*<space>\)\?\zs\(\[[^\]]*\]<space>\)\?\ze./[<space>]<space>/<CR>0t]:noh<CR>
nnoremap <silent> <leader>xx :s/^\s*\(-<space>\\|\*<space>\)\?\zs\(\[[^\]]*\]<space>\)\?\ze./[x]<space>/<CR>0t]:noh<CR>
vnoremap <silent> <leader>xz :s/^\s*\(-<space>\\|\*<space>\)\?\zs\(\[[^\]]*\]<space>\)\?\ze./[<space>]<space>/<CR>0t]:noh<CR>
vnoremap <silent> <leader>xx :s/^\s*\(-<space>\\|\*<space>\)\?\zs\(\[[^\]]*\]<space>\)\?\ze./[x]<space>/<CR>0t]:noh<CR>


