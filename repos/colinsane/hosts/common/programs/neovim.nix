{ config, lib, pkgs, ... }:

let
  inherit (builtins) map;
  inherit (lib) concatMapStrings mkIf optionalString;
  # this structure roughly mirrors home-manager's `programs.neovim.plugins` option
  plugins = with pkgs.vimPlugins; [
    {
      # docs: fzf-vim (fuzzy finder): https://github.com/junegunn/fzf.vim
      plugin = fzf-vim;
    }
    {
      # treesitter syntax highlighting: https://nixos.wiki/wiki/Tree_sitters
      # docs: https://github.com/nvim-treesitter/nvim-treesitter
      # config taken from: https://github.com/i077/system/blob/master/modules/home/neovim/default.nix
      # this is required for tree-sitter to even highlight
      # XXX(2024/06/03): `unison` removed because it doesn't cross compile
      plugin = nvim-treesitter.withPlugins (_: (lib.filter (p: p.pname != "unison-grammar") nvim-treesitter.allGrammars) ++ [
        # XXX: this is apparently not enough to enable syntax highlighting!
        # nvim-treesitter ships its own queries which may be distinct from e.g. helix.
        # the queries aren't included when i ship the grammar in this manner
        pkgs.tree-sitter-nix-shell
      ]);
      type = "lua";
      config = ''
        -- lifted mostly from readme: <https://github.com/nvim-treesitter/nvim-treesitter>
        require'nvim-treesitter.configs'.setup {
          highlight = {
            enable = true,
            -- disable treesitter on Rust so that we can use SyntaxRange
            -- and leverage TeX rendering in rust projects
            disable = { "rust", "tex", "latex" },
            -- disable = { "tex", "latex" },
            -- true to also use builtin vim syntax highlighting when treesitter fails
            additional_vim_regex_highlighting = false
          },
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = "gnn",
              node_incremental = "grn",
              scope_incremental = "grc",
              node_decremental = "grm"
            }
          },
          indent = {
            enable = true,
            disable = {}
          }
        }

        vim.o.foldmethod = 'expr'
        vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
      '';
    }
    {
      # docs: tex-conceal-vim: https://github.com/KeitaNakamura/tex-conceal.vim/
      plugin = tex-conceal-vim;
      type = "viml";
      config = ''
        " present prettier fractions
        let g:tex_conceal_frac=1
      '';
    }
    {
      # source: <https://github.com/LnL7/vim-nix>
      # fixes auto-indent (incl tab size) when editing .nix files
      plugin = vim-nix;
    }
    {
      # docs: surround-nvim: https://github.com/ur4ltz/surround.nvim/
      # docs: vim-surround: https://github.com/tpope/vim-surround
      plugin = vim-surround;
    }
    {
      plugin = vim-SyntaxRange;
      type = "viml";
      config = ''
        " enable markdown-style codeblock highlighting for tex code
        autocmd BufEnter * call SyntaxRange#Include('```tex', '```', 'tex', 'NonText')
        " autocmd Syntax tex set conceallevel=2
      '';
    }
  ];
  plugin-packages = map (p: p.plugin) plugins;
  plugin-config-viml = concatMapStrings (p: optionalString (p.type or "" == "viml") p.config) plugins;
  plugin-config-lua = concatMapStrings (p: optionalString (p.type or "" == "lua") p.config) plugins;
in
{
  sane.programs.neovim = {
    sandbox.method = "bwrap";
    sandbox.autodetectCliPaths = "existingOrParent";
    sandbox.whitelistWayland = true;  # for system clipboard integration
    # sandbox.whitelistPwd = true;
    sandbox.extraHomePaths = [
      # directories where i'm liable to `:e ../...`
      # "archive"
      "dev"
      "knowledge"
      "nixos"
      "records"
      "ref"
      "tmp"
      # "use"
    ];

    packageUnwrapped = let
      configArgs = {
        withRuby = false;  #< doesn't cross-compile w/o binfmt
        viAlias = true;
        vimAlias = true;
        plugins = plugin-packages;
        customRC = ''
          " let the terminal handle mouse events, that way i get OS-level ctrl+shift+c/etc
          " this used to be default, until <https://github.com/neovim/neovim/pull/19290>
          set mouse=

          " copy/paste to system clipboard
          set clipboard=unnamedplus

          " screw tabs; always expand them into spaces
          set expandtab

          " at least don't open files with sections folded by default
          set nofoldenable

          " allow text substitutions for certain glyphs.
          " higher number = more aggressive substitution (0, 1, 2, 3)
          " i only make use of this for tex, but it's unclear how to
          " apply that *just* to tex and retain the SyntaxRange stuff.
          set conceallevel=2

          " horizontal rule under the active line
          " set cursorline

          " highlight trailing space & related syntax errors (doesn't seem to work??)
          " let c_space_errors=1
          " let python_space_errors=1

          " enable highlighting of leading/trailing spaces,
          " and especially tabs
          " source: https://www.reddit.com/r/neovim/comments/chlmfk/highlight_trailing_whitespaces_in_neovim/
          set list
          set listchars=tab:▷\·,trail:·,extends:◣,precedes:◢,nbsp:○

          """"" PLUGIN CONFIG (vim)
          ${plugin-config-viml}

          """"" PLUGIN CONFIG (lua)
          lua <<EOF
          ${plugin-config-lua}
          EOF
        '';
      };
      neovim-unwrapped' = with pkgs; (neovim-unwrapped.override {
        # optional: `neovim` defaults to luajit when not manually wrapping
        lua = luajit;
      }).overrideAttrs (upstream: {
        # fix cross compilation:
        # - neovim vendors lua `mpack` library,
        #   which it tries to build for the wrong platform
        #   and its vendored version has diverged in symbol names anyway
        postPatch = (upstream.postPatch or "") + ''
          substituteInPlace src/nvim/generators/preload.lua --replace-fail \
            "require 'nlua0'" "
              vim.mpack = require 'mpack'
              vim.mpack.encode = vim.mpack.pack
              vim.mpack.decode = vim.mpack.unpack
              vim.lpeg = require 'lpeg'
            "
        ''
        # + lib.optionalString (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
        #   # required for x86_64 -> aarch64 (and probably armv7l too)
        #   substituteInPlace runtime/CMakeLists.txt --replace-fail \
        #     'COMMAND $<TARGET_FILE:nvim_bin>' 'COMMAND ${pkgs.stdenv.hostPlatform.emulator pkgs.buildPackages} $<TARGET_FILE:nvim_bin>'
        # ''
        + ''
          # disable translations and syntax highlighting of .vim files because they don't cross x86_64 -> armv7l
          substituteInPlace src/nvim/CMakeLists.txt --replace-fail \
            'add_subdirectory(po)' '# add_subdirectory(po)'
          # substituteInPlace src/nvim/po/CMakeLists.txt --replace-fail \
          #   'add_dependencies(nvim nvim_translations)' '# add_dependencies(nvim nvim_translations)'
          substituteInPlace runtime/CMakeLists.txt \
            --replace-fail '    ''${GENERATED_SYN_VIM}' '    # ''${GENERATED_SYN_VIM}' \
            --replace-fail '    ''${GENERATED_HELP_TAGS}' '    # ''${GENERATED_HELP_TAGS}' \
            --replace-fail 'FILES ''${GENERATED_HELP_TAGS} ''${BUILDDOCFILES}'  'FILES ''${CMAKE_CURRENT_SOURCE_DIR}/nvim.desktop' \
            --replace-fail 'FILES ''${GENERATED_SYN_VIM}'  'FILES ''${CMAKE_CURRENT_SOURCE_DIR}/nvim.desktop' \
            --replace-fail 'if(''${PACKNAME}_DOC_FILES)' 'if(false)'
          # --replace-fail '    ''${GENERATED_PACKAGE_TAGS}' '     # ''${GENERATED_PACKAGE_TAGS}' \
          # --replace-fail 'list(APPEND BUILDDOCFILES' '# list(APPEND BUILDDOCFILES'
          # --replace-fail '  FILES ''${GENERATED_HELP_TAGS} ' '  FILES ' \
        '';
      });
    in pkgs.wrapNeovimUnstable
      neovim-unwrapped'
      # XXX(2024/05/13): manifestRc must be null for cross-compilation to work.
      #   wrapper invokes `neovim` with all plugins enabled at build time i guess to generate caches and stuff?
      #   alternative is to emulate `nvim-wrapper` during build.
      ((pkgs.neovimUtils.makeNeovimConfig configArgs) // { manifestRc = null; })
    ;

    # private because there could be sensitive things in the swap
    persist.byStore.private = [ ".cache/vim-swap" ];
    env.EDITOR = "vim";
    # git claims it should use EDITOR, but it doesn't!
    env.GIT_EDITOR = "vim";
    mime.priority = 200;  # default=100 => yield to other, more specialized applications
    mime.associations."application/schema+json" = "nvim.desktop";
    mime.associations."plain/text" = "nvim.desktop";
    mime.associations."text/markdown" = "nvim.desktop";
  };
}
