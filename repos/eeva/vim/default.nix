{ pkgs
, ...
}:

# At first, largely adapted from:
# https://www.mpscholten.de/nixos/2016/04/11/setting-up-vim-on-nixos.html
# Changed quite a bit since

with pkgs;

let
  plugins = let inherit (vimUtils) buildVimPluginFrom2Nix; in {
  "vim-terraform" = buildVimPluginFrom2Nix { # created by nix#NixDerivation
    name = "vim-terraform";
    src = fetchFromGitHub {
      owner = "hashivim";
      repo = "vim-terraform";
      rev = "76799270813db362b13a56f26cd34f668e9e17a4";
      sha256 = "0j3cnnvhs41phz0kiyaprp05vxhf5jaaw5sn5jcn08yc6jhy009r";
    };
    dependencies = [];
  };
  "better-whitespace" = buildVimPluginFrom2Nix { # created by nix#NixDerivation
    name = "better-whitespace";
    src = fetchgit {
      url = "git://github.com/ntpeters/vim-better-whitespace";
      rev = "7729bada7ad8d341b910367da8a900490bd15e86";
      sha256 = "0kkj13jjzjyv2b17sk8bka2d55czz7v6xvv0zz1i8qidvg6lbniw";
    };
    dependencies = [];
  };
  "systemd-syntax" = buildVimPluginFrom2Nix { # created by nix#NixDerivation
    name = "systemd-syntax";
    src = fetchgit {
      url = "git://github.com/Matt-Deacalion/vim-systemd-syntax";
      rev = "05bd51f87628e4b714b9d1d16259e1ead845924a";
      sha256 = "04jlbm4cf47kvys22czz1i3fcqzz4zih2h6pkcfns9s8rs6clm3c";
    };
    dependencies = [];
  };
  "opencl-syntax" = buildVimPluginFrom2Nix { # created by nix#NixDerivation
    name = "opencl-syntax";
    src = fetchgit {
      url = "git://github.com/petRUShka/vim-opencl";
      rev = "a75693fdb1526cf0f2f2d1a6bdc23d6537ac1b6f";
      sha256 = "0ba3kj65h2lsn7s0fazhmbaa7nr8b9ssda3i54259mcc4nhwvi7b";
    };
    dependencies = [];
  };
  "speeddating" = buildVimPluginFrom2Nix { # created by nix#NixDerivation
    name = "speeddating";
    src = fetchgit {
      url = "git://github.com/tpope/vim-repeat.git";
      rev = "070ee903245999b2b79f7386631ffd29ce9b8e9f";
      sha256 = "1grsaaar2ng1049gc3r8wbbp5imp31z1lcg399vhh3k36y34q213";
    };
    dependencies = [];
  };
  "vim-gnupg" = buildVimPluginFrom2Nix { # created by nix#NixDerivation
    name = "vim-gnupg";
    src = fetchFromGitHub {
      owner = "jamessan";
      repo = "vim-gnupg";
      rev = "5b069789e237ca43533a229580822772640ce301";
      sha256 = "0jkxbk0hw3mcvigz3z2f2a91bizdanm392h32068s110bm1fa8xs";
    };
    dependencies = [];
  };
}; in vim_configurable.customize {
    name = "vim";
    vimrcConfig.packages.myVimPackage = with pkgs.vimPlugins; with plugins; {
      # loaded on launch
      start = [
        Solarized
        better-whitespace
        calendar-vim
        elm-vim
        fzf-vim
        fzfWrapper
        nerdtree
        repeat
        speeddating
        surround
        systemd-syntax
        vim-airline
        vim-airline-themes
        vim-gnupg
        vim-nix
        vim-orgmode
        vim-terraform
        vimtex
        vimwiki
      ];
      # manually loadable by calling `:packadd $plugin-name`
      opt = [
      ];
      # To automatically load a plugin when opening a filetype, add vimrc lines like:
      # autocmd FileType php :packadd phpCompletion
    };
    vimrcConfig.customRC = ''
      " Must have for vim
      set nocompatible

      " Display nbsp
      set listchars=tab:\|\ ,nbsp:·
      set list

      " Remap ESC on ,,
      map ,, <ESC>
      imap ,, <ESC>

      scriptencoding utf-8

      " Must be *after* pathogen (not using pathogen anymore)
      filetype plugin indent on

      " Leader
      let mapleader=","
      nnoremap <leader>a :echo("\<leader\> works! It is set to <leader>")<CR>
      " let maplocalleader = "-"

      " Highlighting
      syntax enable
      if has('gui_running')
          " When gui is running, it pretty much sets its own colors
          set background=dark
          set guifont="Iosevka Term 10"
          set notitle
          set guioptions=a
      else
          " If we're in a terminal, then we stay default, terminal will choose
          " which colors it likes.
          set background=dark
      endif

      let g:solarized_termcolors=16
      let g:airline_solarized_bg='dark'
      colorscheme solarized

      " Set line numbering
      set number

      " Don't wrap lines, it's ugly
      set nowrap

      " Deal with tabs
      set softtabstop=2
      set tabstop=2    " 1 tab = 2 spaces
      set shiftwidth=2 " Indent with 2 spaces
      set expandtab    " Insert spaces instead of tabs

      " Set par as default wrapper
      set formatprg=${par.outPath}/bin/par\ -w80

      " Set mouse on
      set mouse=a

      " Don't set timeout - this breaks the leader use
      set notimeout
      set ttimeout

      " Color lines in a different shade up to 80 columns
      let &colorcolumn=join(range(81,999),",")

      " automatically jump to the end of the text you just copied/pasted:
      xnoremap <silent> y y`]
      nnoremap <silent> yy yy`]
      xnoremap <silent> p p`]
      xnoremap <silent> P P`]
      nnoremap <silent> p p`]
      nnoremap <silent> P P`]

      " vimtex options
      let g:vimtex_fold_enabled=1
      let g:vimtex_fold_manual=1
      let g:vimtex_compiler_enabled=0

      " conceal to unicode symbols
      nnoremap <leader>l :silent let &conceallevel = (&conceallevel+1)%4<CR>
      set conceallevel=2
      set concealcursor=nvc
      let g:tex_conceal="abdmgs"

      " nice pluginless stuff
      set path+=**
      set wildmenu

      " Tag generation
      command! MakeTags !ctags -R .

      " Less noise in netrw
      let g:netrw_altv=1
      let g:netrw_banner=0
      let g:netrw_browse_split=4
      let g:netrw_list_hide=netrw_gitignore#Hide()
      let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'
      let g:netrw_liststyle=3
      let g:netrw_winsize=25

      " Normal backspace
      set backspace=indent,eol,start

      " Set filetype tex for tikz files
      au BufNewFile,BufRead *.tikz set filetype=tex

      " vimwiki stuff
      let g:vimwiki_list = [
        \{'path': '~/vimwiki/personal.wiki'}
      \]
      au BufRead,BufNewFile *.wiki set filetype=vimwiki
      :autocmd FileType vimwiki map <leader>d :VimwikiMakeDiaryNote
      function! ToggleCalendar()
        execute ":Calendar"
        if exists("g:calendar_open")
          if g:calendar_open == 1
            execute "q"
            unlet g:calendar_open
          else
            g:calendar_open = 1
          end
        else
          let g:calendar_open = 1
        end
      endfunction
      :autocmd FileType vimwiki map <leader>c :call ToggleCalendar()

      " Thx Mats for the following
      :cnoremap <C-A> <Home>
      :cnoremap <C-B> <Left>
      :cnoremap <C-F> <Right>
      :cnoremap <C-E> <End>

      " NERDTree when starting
      "autocmd vimenter * NERDTree
      let g:NERDTreeDirArrowExpandable  = '+'
      let g:NERDTreeDirArrowCollapsible = '-'
    '';
}
