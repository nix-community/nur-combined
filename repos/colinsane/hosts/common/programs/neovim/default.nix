# useful vim config references:
# - <repo:nix-community/nur-combined:repos/ambroisie/modules/home/vim>
# - <https://nix-community.github.io/nixvim/user-guide/config-examples.html>
# - <https://matrix.to/#/#nixvim:matrix.org>
moduleArgs@{ config, lib, pkgs, ... }:

let
  cfg = config.sane.programs.neovim.config;
  plugins = import ./plugins.nix moduleArgs;
  plugin-packages = builtins.filter (x: x != null) (
    lib.concatMap (p: (p.plugins or []) ++ (if p ? plugin then [ p.plugin ] else [])) plugins
  );
  plugin-configs = lib.concatMapStrings (p:
    lib.optionalString
      (p ? config) (
        if (p.type or "") == "viml" then
          p.config
        else
          ''
            lua <<EOF
            ${p.config}
            EOF
          ''
      )
  ) plugins;
in
{
  sane.programs.neovim = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options = {
          scrollbackMax = mkOption {
            description = ''
              SB_MAX: maximum lines nvim will buffer in-memory.
              higher values make for better pagination (especially for `page` program),
              but also allow nvim to consume more memory.

              considerations:
              - page/neovim uses about 3GB of RAM per 1M lines.
              - `git log` for nixpkgs: about 5_000_000 lines (~15 GB).
              - `git log` for linux: about 25_000_000 lines (~75 GB).
            '';
            type = types.int;
            default = 100000000;
          };
        };
      };
    };

    suggestedPrograms = [
      # find language servers...
      # - in nixpkgs:
      #   `rg -i 'language server'`
      # - <https://github.com/neovim/nvim-lspconfig>
      # - <https://langserver.org/>
      "bash-language-server"
      # "ccls"  # for c/c++. can't get it to actually load. <https://github.com/MaskRay/ccls>
      # "clang-tools"  # for c/c++. fails to follow #includes; "Too many errors emitted"
      "ctags-lsp"  # for TAGS (ctags)
      "dasht"  # for vim-dasht; docset queries
      "lua-language-server"
      # "ltex-ls"  # LaTeX, html, markdown spellchecker (but it's over-eager, and resource-heavy)
      "marksman"  # markdown
      "mesonlsp"  # meson
      "nixd"  # Nix
      "openscad-lsp"  # OpenSCAD (limited)
      "pyright"  # python
      "rust-analyzer"  # Rust (limited)
      # "sourcekit-lsp"  # Swift/C/C++. "Too many errors" if unconfigured.  <https://github.com/swiftlang/sourcekit-lsp>
      "systemd-lsp"  # .unit files
      "typescript-language-server"

      # these could be cool, i just haven't bothered to integrate them:
      # "asm-lsp"
      # "autotools-language-server"
      # "awk-language-server"
      # "crates-lsp"  # Cargo.toml
      # "css_variables"  # CSS. 2025-10-23: not packaged for nix  <https://github.com/vunguyentuan/vscode-css-variables/tree/master/packages/css-variables-language-server>
      # "dts-lsp"  # Device Tree
      # "ginko"  # Device Tree
      # "gopls"  # Go
      # "java-language-server"
      # "javascript-typescript-langserver"
      # "jdt-language-server"  # Java
      # "jinja-lsp"  # .jinja2
      # "jq-lsp"  # jq
      # "lemminx"  # XML language server  <https://github.com/eclipse/lemminx>
      # "md-lsp"  # Markdown
      # "mpls"  # Markdown ("live preview", so, a Markdown renderer?)
      # "nginx-language-server"
      # "nil"  # nix
      # "pylyzer"  # Python
      # "sqls"  # SQL
      # "superhtml"  # HTML  <https://github.com/kristoff-it/superhtml>
      # "svlsp"  # SystemVerilog
      # "systemd-language-server"  # .unit files
      # "texlab"  # Tex
      # "textlsp"  # spellchecker
      # "ty"  # Python
      # "typescript-language-server"  # Typescript
      # "vala-language-server"  #< 2024-08-26: fails to recognize any imported types, complains they're all `null`
      # "vim-language-server"  # vimscript
      # "yaml-language-server"
      # "zuban"  # Python ("mypy compatible")
    ];

    sandbox.autodetectCliPaths = "existingOrParent";
    sandbox.whitelistWayland = true;  # for system clipboard integration
    # sandbox.whitelistPwd = true;
    sandbox.extraHomePaths = [
      ".local/share/dasht/docsets"
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
    sandbox.tryKeepUsers = true;
    sandbox.capabilities = [ "dac_override" ];

    packageUnwrapped = let
      neovim-unwrapped' = with pkgs; neovim-unwrapped.overrideAttrs (upstream: {
        # allow for more scrollback, especially required when neovim is used inside `PAGER=page`
        postPatch = (upstream.postPatch or "") + ''
          substituteInPlace src/nvim/option_vars.h \
            --replace-fail '#define SB_MAX ' '#define SB_MAX ${toString cfg.scrollbackMax} //'
        ''
        # fix cross compilation:
        # - neovim vendors lua `mpack` library,
        #   which it tries to build for the wrong platform
        #   and its vendored version has diverged in symbol names anyway
        # TODO: lift this into `overlays/cross.nix`, where i can monitor its upstreaming!
        + ''
          substituteInPlace src/gen/preload_nlua.lua --replace-fail \
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
    in (pkgs.wrapNeovimUnstable neovim-unwrapped' {
      plugins = plugin-packages;
      viAlias = true;
      vimAlias = true;
      wrapRc = false;  #< don't force VIMINIT env var; let nvim load config from ~/.config/nvim/init.vim instead
      # withRuby = false;  #< doesn't cross-compile w/o binfmt
      # customRC = ''
      #   ${builtins.readFile ./vimrc}
      #   """"" PLUGIN CONFIG
      #   ${plugin-configs}
      # '';
    }).overrideAttrs(base: {
      # XXX(2026-04-18): neovim wrapper wants to invoke nvim at build time to generate "rplugin" manifests, but that errors when cross compiling.
      # my rplugin manifest is always empty, so disabling that step loses nothing.
      # N.B. if this wrapper continues to cause problems, i could just ship `neovim-unwrapped` and instead
      # link the plugins into the fs (e.g. ~/.config/nvim/pack/myPlugin/start/myPlugin -> ${pkgs.myPlugin}), for each `myPlugin`.
      # see: <https://neovim.io/doc/user/pack/>
      postBuild = lib.replaceStrings [ "if ! $out/bin/nvim-wrapper " ] [ "if false " ] base.postBuild;
    });

    fs.".config/nvim/init.vim".symlink.text = ''
      ${builtins.readFile ./vimrc}

      """"" PLUGIN CONFIG
      ${plugin-configs}
    '';

    # ~/.local/state/nvim/lsp.log can grow to 1 GB+
    persist.byStore.ephemeral = [ ".local/state/nvim" ];
    # private because there could be sensitive things in the swap
    persist.byStore.private = [ ".cache/vim-swap" ];  #< TODO: does this live in ~/.local/state/nvim/swap, now?
    env.EDITOR = "vim";
    # git falls back to EDITOR if GIT_EDITOR is unspecified
    # env.GIT_EDITOR = "vim";
    mime.priority = 200;  # default=100 => yield to other, more specialized applications
    mime.associations."application/schema+json" = "nvim.desktop";
    mime.associations."plain/text" = "nvim.desktop";
    mime.associations."text/markdown" = "nvim.desktop";
  };
}
