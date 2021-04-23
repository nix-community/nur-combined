" Yank until the end of line with Y, to be more consistent with D and C
nnoremap Y y$

" Run make silently, then skip the 'Press ENTER to continue'
noremap <Leader>m :silent! :make! \| :redraw!<CR>

" Remove search-highlighting
noremap <Leader><Leader> :nohls<CR>
