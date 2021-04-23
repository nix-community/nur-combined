" Only git-tracked files, Vim needs to be in a Git repository
nnoremap <Leader>fg :GFiles<CR>

" All files
nnoremap <Leader>ff :Files<CR>

" Currently open buffers
nnoremap <Leader>fb :Buffers<CR>

" Buffer history
nnoremap <Leader>fh :History<CR>

" Tags in buffer
nnoremap <Leader>ft :BTags<CR>

" Tags in all project files
nnoremap <Leader>fT :Tags<CR>

" Snippets for the current fileytpe (using Ultisnips)
nnoremap <Leader>fs :Snippets<CR>

" All available commands
nnoremap <Leader>f: :Commands<CR>

" All commits (using fugitive)
nnoremap <Leader>fc :Commits<CR>

" All commits for the current buffer (using fugitive)
nnoremap <Leader>fC :BCommits<CR>

" Select normal mode mapping by searching for its name
nmap <Leader><Tab> <Plug>(fzf-maps-n)

" Select visual mode mapping by searching for its name
xmap <Leader><Tab> <Plug>(fzf-maps-x)

" Select operator pending mode mapping by searching for its name
omap <Leader><Tab> <Plug>(fzf-maps-o)
