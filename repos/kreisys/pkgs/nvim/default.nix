{ lib, vimUtils, vimPlugins, neovim, fetchgit }:

with vimPlugins;
let
  fetchgit' = url: let
    srcs = lib.importJSON ./srcs.json;
    src  = srcs.${url};
  in fetchgit { inherit (src) url rev sha256 fetchSubmodules; };

  buildVimPlugin = vimUtils.buildVimPluginFrom2Nix;

  oceanic-next = buildVimPlugin {
    name = "oceanic-next";
    src = fetchgit' https://github.com/mhartington/oceanic-next;
    dependencies = [];
  };

  vim-nerdtree-syntax-highlight = buildVimPlugin {
    name = "vim-nerdtree-syntax-highlight";
    src = fetchgit' https://github.com/tiagofumo/vim-nerdtree-syntax-highlight;
    dependencies = [];
  };

  github-issues = buildVimPlugin {
    name = "github-issues";
    src = fetchgit' https://github.com/jaxbot/github-issues.vim;
    dependencies = [];
  };

  vim-hashicorp-tools = buildVimPlugin {
    name = "vim-hashicorp-tools";
    src = fetchgit' https://github.com/hashivim/vim-hashicorp-tools;
    dependencies = [];
  };

  vim-fish = buildVimPlugin {
    name = "vim-fish";
    src = fetchgit' https://github.com/dag/vim-fish;
    dependencies = [];
  };

  purescript-vim = buildVimPlugin {
    name = "purescript-vim";
    src = fetchgit' https://github.com/purescript-contrib/purescript-vim;
    dependencies = [];
  };

  typescript-vim = buildVimPlugin {
    name = "typescript-vim";
    src = fetchgit' https://github.com/leafgarland/typescript-vim;
    dependencies = [];
  };

  vimrcGeneralConfig = ''
    if (has("termguicolors"))
      set termguicolors
    endif
    set encoding=utf8
    scriptencoding utf8
    " Enable mouse
    set mouse=a
    " Set <Leader> to comma
    let g:mapleader=','
    " Enable syntax highlighting
    syntax on
    " Allow per-project .vimrc
    set exrc
    set secure
    " Use macOS clipboard
    set clipboard=unnamed
    " Set color scheme
    let g:oceanic_next_terminal_bold = 1
    let g:oceanic_next_terminal_italic = 1
    silent! colorscheme OceanicNext
    " Enable hybrid line numbers
    set relativenumber
    set number
    highlight CursorLineNr term=bold ctermfg=Yellow     gui=bold guifg=Yellow
    highlight LineNr       term=none ctermfg=DarkYellow gui=none guifg=DarkYellow

    map <Leader>/ :noh<CR>

    set spellsuggest=15
    set linebreak
    set scrolloff=3
    set foldcolumn=1
    set scrolloff=999
    " sudo save
    command W execute 'silent! write !sudo tee % > /dev/null' <bar> edit!
    " Enable indent guides
    let g:indent_guides_enable_on_vim_startup = 1
  '';

  vimrcAirlineConfig = ''
    " Enable Powerline fonts
    let g:airline_powerline_fonts = 1
    " Enable tabs
    let g:airline#extensions#tabline#enabled = 1
    let g:airline_theme='oceanicnext'
    let g:airline_left_sep = "\uE0B4"
    let g:airline_right_sep = "\uE0B6"
    " Set the CN (column number) symbol:
    ""let g:airline_section_z = airline#section#create(["\uE0A1" . '%{line(".")}' . "\uE0A3" . '%{col(".")}'])
  '';

  vimrcDeopleteConfig = ''
    let g:deoplete#enable_at_startup = 1
    let g:deoplete#num_processes = 1
    inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
  '';

  vimrcTabularConfig = ''
    if exists(':Tabularize')
      nmap <Leader>t= :Tabularize /=<CR>
      vmap <Leader>t= :Tabularize /=<CR>
      nmap <Leader>t: :Tabularize /:\zs<CR>
      vmap <Leader>t: :Tabularize /:\zs<CR>
      nmap <Leader>t, :Tabularize /,\zs<CR>
      vmap <Leader>t, :Tabularize /,\zs<CR>
    endif
  '';

  vimrcNERDTreeConfig = ''
    let g:WebDevIconsUnicodeDecorateFolderNodes = 1
    let g:DevIconsEnableFoldersOpenClose = 1
    let g:WebDevIconsUnicodeDecorateFolderNodes = 1
    let g:NERDTreeMinimalUI = 1
    let g:NERDTreeDirArrowExpandable = ' '
    let g:NERDTreeDirArrowCollapsible = ' '
    let g:NERDTreeExactMatchHighlightFullName = 1
    let g:NERDTreeHighlightFolders = 1 " enables folder icon highlighting using exact match
    let g:NERDTreeHighlightFoldersFullName = 1 " highlights the folder name
    " Toggle with Ctrl+n
    map <C-n> :NERDTreeToggle<CR>
    " Open a NERDTree automatically when...
    augroup nertdree
      autocmd StdinReadPre * let s:std_in=1
      " `- vim starts up if no files were specified:
      autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
      " `- vim starts up on opening a directory:
      autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
    augroup END
  '';

  vimrcTerraformConfig = ''
    let g:terraform_fmt_on_save = 1
  '';

  vimrcDeviconsConfig = ''
    if exists('g:loaded_webdevicons')
      call webdevicons#refresh()
    endif
  '';

  vimrcGoyoAndLimelightConfig = ''
    map <Leader>w :Goyo<CR>
    augroup goyo
      autocmd! User GoyoEnter Limelight0.7
      autocmd! User GoyoLeave Limelight!
    augroup END
  '';

  vimrcALEConfig = ''
    let g:airline#extensions#ale#enabled = 1
    " Put this in vimrc or a plugin file of your own.
    " After this is configured, :ALEFix will try and fix your JS code with ESLint.
    let g:ale_fixers = {
    \   'javascript': ['eslint'],
    \}

    "let g:ale_fixers = {
    "\   'haskell': ['cabal_ghc'],
    "\}

    " Set this setting in vimrc if you want to fix files automatically on save.
    " This is off by default.
    let g:ale_fix_on_save = 1
  '';

  vimrcJavascriptConfig = ''
    let g:javascript_conceal_function             = "ƒ"
    let g:javascript_conceal_null                 = "ø"
    let g:javascript_conceal_this                 = "@"
    let g:javascript_conceal_return               = "⇚"
    let g:javascript_conceal_undefined            = "¿"
    let g:javascript_conceal_NaN                  = "ℕ"
    let g:javascript_conceal_prototype            = "¶"
    let g:javascript_conceal_static               = "•"
    let g:javascript_conceal_super                = "Ω"
    let g:javascript_conceal_arrow_function       = "⇒"
    let g:javascript_conceal_noarg_arrow_function = "🞅"
    let g:javascript_conceal_underscore_arrow_function = "🞅"

    augroup javascript_folding
        au!
        au FileType javascript setlocal foldmethod=syntax
    augroup END

    map <leader>l :exec &conceallevel ? "set conceallevel=0" : "set conceallevel=1"<CR>
  '';

  vimrcEasyAlignConfig = ''
    " Align GitHub-flavored Markdown tables
    au FileType markdown vmap <Leader><Bslash> :EasyAlign*<Bar><Enter>
  '';

  vimrc = ''
    ${vimrcGeneralConfig}
    ${vimrcAirlineConfig}
    ${vimrcDeopleteConfig}
    ${vimrcTabularConfig}
    ${vimrcNERDTreeConfig}
    ${vimrcTerraformConfig}
    ${vimrcDeviconsConfig}
    ${vimrcGoyoAndLimelightConfig}
    ${vimrcEasyAlignConfig}
    ${vimrcALEConfig}
  '';
    #${vimrcJavascriptConfig}

  languagePlugins = [
    coffee-script
    haskell-vim
    vim-go
    vim-hashicorp-tools
    vim-javascript
    vim-json
    vim-ledger
    vim-markdown
    vim-nix
    vim-fish
    purescript-vim
    typescript-vim
  ];

  utilityPlugins = [
    ale
    auto-pairs
    deoplete-nvim
    easy-align
    editorconfig-vim
    fugitive
    gitgutter
    goyo
    limelight-vim
    nerdcommenter
    nerdtree
    nerdtree-git-plugin
    surround
    tabular
    vim-airline
    vim-indent-guides
    vim-repeat
  ];

  cosmeticPlugins = [
    oceanic-next
    vim-devicons
    vim-nerdtree-syntax-highlight
  ];

  allPlugins = languagePlugins ++ utilityPlugins ++ cosmeticPlugins;

  start = allPlugins;

in neovim.override {
  vimAlias = true;
  viAlias = true;

  configure = {
    packages.myVimPackage = {
      inherit start;
    };

    customRC = vimrc;
 };
}
