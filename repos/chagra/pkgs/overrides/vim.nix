{ pkgs }:

pkgs.neovim.override {
  withPython = false;
  withPython3 = true;
  withRuby = false;
  withNodeJs = false;

  vimAlias = true;
  viAlias = true;

  configure = {
    customRC = ''
      set nocompatible
      filetype off
      colorscheme wal
      let mapleader = ","

      " basics
      set bg=light
      set go=a
      set mouse=a
      set clipboard=unnamedplus
      set number relativenumber
      filetype plugin indent on
      filetype plugin on
      syntax on
      set clipboard=unnamedplus
      set encoding=utf-8

      "airline
      let g:airline_theme='base16color'

      " autocomplete
      set wildmode=longest,list,full

      "super tab
      set completeopt=longest,menuone

      " Disable automatic commenting on newline
      autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

      " Goyo
      map <leader>f :Goyo<CR> :colorscheme desert<CR>

      " Spell-check set to <leader>o, 'o' for 'orthography':
      map <leader>o :setlocal spell! spelllang=fr,en<CR>

      " Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
      set splitbelow splitright

      " Shortcutting split navigation, saving a keypress:
      	map <C-h> <C-w>h
      	map <C-j> <C-w>j
      	map <C-k> <C-w>k
      	map <C-l> <C-w>l

      " Automatically deletes all trailing whitespace on save.
      	autocmd BufWritePre * %s/\s\+$//e

      " Navigating with guides
      	inoremap <leader><leader> <Esc>/<++><Enter>"_c4l
      	vnoremap <leader><leader> <Esc>/<++><Enter>"_c4l
      	map <leader><leader> <Esc>/<++><Enter>"_c4l

      " open up vim.nix
        map <leader>v <Esc>:vsplit ~/.local/repos/nur-packages/pkgs/overrides/vim.nix<Enter>
      	inoremap <leader>v <Esc>:vsplit ~/.local/repos/nur-packages/pkgs/overrides/vim.nix<Enter>
      	vnoremap <leader>v <Esc>:vsplit ~/.local/repos/nur-packages/pkgs/overrides/vim.nix<Enter>

      " set nohlsearch
      	nnoremap <esc> :noh<return><esc>

      " Sourcing from home for quick changes
      if $USER != 'root'
        if filereadable("~/.extravimrc")
          source ~/.extravimrc
        endif
      endif


      """LATEX
        " Compile document, be it groff/LaTeX/markdown/etc.
        autocmd FileType tex map <leader>c :w! \| !compilelatex <c-r>%<CR>

        " Open corresponding .pdf/.html or preview
        autocmd FileType tex map <leader>p :!openpreview <c-r>%<CR><CR>

        " Runs a script that cleans out tex build files whenever I close out of a .tex file.
      	autocmd VimLeave *.tex !texclear %

      	" Word count:
      	autocmd FileType tex map <leader>w :w !detex \| wc -w<CR>

      	" Code snippets
      	autocmd FileType tex inoremap ,fr \begin{frame}<Enter>\frametitle{}<Enter><Enter><++><Enter><Enter>\end{frame}<Enter><Enter><++><Esc>6kf}i
      	autocmd FileType tex inoremap ,fi \begin{fitch}<Enter><Enter>\end{fitch}<Enter><Enter><++><Esc>3kA
      	autocmd FileType tex inoremap ,exe \begin{exe}<Enter>\ex<Space><Enter>\end{exe}<Enter><Enter><++><Esc>3kA
      	autocmd FileType tex inoremap ,em \emph{}<++><Esc>T{i
      	autocmd FileType tex inoremap ,bf \textbf{}<++><Esc>T{i
      	autocmd FileType tex inoremap ,un \underline{}<++><Esc>T{i
      	autocmd FileType tex inoremap ,colo {\color{}<++>}<++><Esc>T{i
      	autocmd FileType tex inoremap ,graph \includegraphics[]{<++>}<++><Esc>T[i
      	autocmd FileType tex vnoremap , <ESC>`<i\{<ESC>`>2la}<ESC>?\\{<Enter>a
      	autocmd FileType tex inoremap ,it \textit{}<++><Esc>T{i
      	autocmd FileType tex inoremap ,ct \textcite{}<++><Esc>T{i
      	autocmd FileType tex inoremap ,cp \parencite{}<++><Esc>T{i
      	autocmd FileType tex inoremap ,x \begin{xlist}<Enter>\ex<Space><Enter>\end{xlist}<Esc>kA<Space>
      	autocmd FileType tex inoremap ,ol \begin{enumerate}<Enter><Enter>\end{enumerate}<Enter><Enter><++><Esc>3kA\item<Space>
      	autocmd FileType tex inoremap ,ul \begin{itemize}<Enter><Enter>\end{itemize}<Enter><Enter><++><Esc>3kA\item<Space>
      	autocmd FileType tex inoremap ,li <Enter>\item<Space>
      	autocmd FileType tex inoremap ,ref \ref{}<Space><++><Esc>T{i
      	autocmd FileType tex inoremap ,tabl \begin{tabular}<Enter><++><Enter>\end{tabular}<Enter><Enter><++><Esc>4kA{}<Esc>i
      	autocmd FileType tex inoremap ,tabu \begin{tabu}<Space>to<Space>\textwidth<Space>{}<Enter><++><Enter>\end{tabu}<Enter><Enter><++><Esc>4k2f{a
      	autocmd FileType tex inoremap ,ot \begin{tableau}<Enter>\inp{<++>}<Tab>\const{<++>}<Tab><++><Enter><++><Enter>\end{tableau}<Enter><Enter><++><Esc>5kA{}<Esc>i
      	autocmd FileType tex inoremap ,can \cand{}<Tab><++><Esc>T{i
      	autocmd FileType tex inoremap ,ce \begin{center}<Enter><Enter>\end{center}<Enter><Enter><++><Esc>3kA
      	autocmd FileType tex inoremap ,bl \begin{block}{}<Enter><++><Enter>\end{block}<Enter><Enter><++><Esc>4k2f}i
      	autocmd FileType tex inoremap ,fig \begin{figure}<Enter><Enter>\end{figure}<Enter><Enter><++><Esc>3kA
      	autocmd FileType tex inoremap ,wfig \begin{wrapfigure}{}{<++>}<Enter><++><Enter>\end{wrapfigure}<Enter><Enter><++><Esc>4k2f{a
      	autocmd FileType tex inoremap ,abst \begin{abstract}<Enter><Enter>\end{abstract}<Enter><Enter><++><Esc>3kA
      	autocmd FileType tex inoremap ,con \const{}<Tab><++><Esc>T{i
      	autocmd FileType tex inoremap ,a \href{}{<++>}<Space><++><Esc>2T{i
      	autocmd FileType tex inoremap ,sc \textsc{}<Space><++><Esc>T{i
      	autocmd FileType tex inoremap ,chap \chapter{}<Enter><Enter><++><Esc>2kf}i
      	autocmd FileType tex inoremap ,sec \section{}<Enter><Enter><++><Esc>2kf}i
      	autocmd FileType tex inoremap ,ssec \subsection{}<Enter><Enter><++><Esc>2kf}i
      	autocmd FileType tex inoremap ,sssec \subsubsection{}<Enter><Enter><++><Esc>2kf}i
      	autocmd FileType tex inoremap ,para \paragraph{}<Enter><Enter><++><Esc>2kf}i
      	autocmd FileType tex inoremap ,st <Esc>F{i*<Esc>f}i
      	autocmd FileType tex inoremap ,beg \begin{DELRN}<Enter><++><Enter>\end{DELRN}<Enter><Enter><++><Esc>4k0fR:MultipleCursorsFind<Space>DELRN<Enter>c
      	autocmd FileType tex inoremap ,up <Esc>/usepackage<Enter>o\usepackage{}<Esc>i
      	autocmd FileType tex inoremap ,tt \texttt{}<Space><++><Esc>T{i
      	autocmd FileType tex inoremap ,bt \blindtext
      	autocmd FileType tex inoremap ,nu $\varnothing$
      	autocmd FileType tex inoremap ,colu \begin{columns}[T]<Enter>\begin{column}{.5\textwidth}<Enter><Enter>\end{column}<Enter>\begin{column}{.5\textwidth}<Enter><++><Enter>\end{column}<Enter>\end{columns}<Esc>5kA
      	autocmd FileType tex inoremap ,rn (\ref{})<++><Esc>F}i


    '';
    packages.myVimPackage = with pkgs.vimPlugins; {
      start = [
        goyo-vim
        vim-airline
        vim-airline-themes
        vim-nix
        supertab
        wal-vim
      ];
      opt = [ ];
    };
  };
}
