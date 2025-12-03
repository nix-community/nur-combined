# useful vim config references:
# - <repo:nix-community/nur-combined:repos/ambroisie/modules/home/vim>
moduleArgs@{ config, lib, pkgs, ... }:

let
  cfg = config.sane.programs.neovim.config;
  plugins = import ./plugins.nix moduleArgs;
  plugin-packages = builtins.filter (x: x != null) (
    builtins.map (p: p.plugin or null) plugins
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
      "bash-language-server"
      # "clang-tools"  # for c/c++. fails to follow #includes; "Too many errors emitted"
      "dasht"  # for vim-dasht; docset queries
      "lua-language-server"
      # "ltex-ls"  # LaTeX, html, markdown spellchecker (but it's over-eager, and resource-heavy)
      "marksman"  # markdown
      "nixd"  # Nix
      "openscad-lsp"  # OpenSCAD (limited)
      "pyright"  # python
      "rust-analyzer"  # Rust (limited)
      "typescript-language-server"

      # these could be cool, i just haven't bothered to integrate them:
      # "css_variables"  # CSS. 2025-10-23: not packaged for nix. <https://github.com/vunguyentuan/vscode-css-variables/tree/master/packages/css-variables-language-server>
      # "lemminx"  # XML language server, in nixpkgs <https://github.com/eclipse/lemminx>
      # "superhtml"  # HTML, in nixpkgs <https://github.com/kristoff-it/superhtml>
      # "vala-language-server"  #< 2024-08-26: fails to recognize any imported types, complains they're all `null`
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
      configArgs = {
        withRuby = false;  #< doesn't cross-compile w/o binfmt
        viAlias = true;
        vimAlias = true;
        plugins = plugin-packages;
        # customRC = ''
        #   ${builtins.readFile ./vimrc}

        #   """"" PLUGIN CONFIG
        #   ${plugin-configs}
        # '';
      };
      neovim-unwrapped' = with pkgs; neovim-unwrapped.overrideAttrs (upstream: {
        # allow for more scrollback, especially required when neovim is used inside `PAGER=page`
        postPatch = (upstream.postPatch or "") + ''
          substituteInPlace src/nvim/option_vars.h \
            --replace-fail '#define SB_MAX ' '#define SB_MAX ${builtins.toString cfg.scrollbackMax} //'
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
    in (pkgs.wrapNeovimUnstable
      neovim-unwrapped'
      # XXX(2024/05/13): manifestRc must be null for cross-compilation to work.
      #   wrapper invokes `neovim` with all plugins enabled at build time i guess to generate caches and stuff?
      #   alternative is to emulate `nvim-wrapper` during build.
      ((pkgs.neovimUtils.makeNeovimConfig configArgs) // { manifestRc = null; })
    ).overrideAttrs(base: {
      # XXX(2024/10/13): the manifestRc and withRuby knobs from earlier are no longer effective,
      # due to <https://github.com/NixOS/nixpkgs/pull/344541>
      rubyEnv = null;
      withRuby = false;
      wrapRc = false;  #< don't force VIMINIT env var
      postBuild = lib.replaceStrings [ "if ! $out/bin/nvim-wrapper " ] [ "if false " ] base.postBuild;
    });

    fs.".config/nvim/init.vim".symlink.text = ''
      ${builtins.readFile ./vimrc}

      """"" PLUGIN CONFIG
      ${plugin-configs}
    '';

    # private because there could be sensitive things in the swap
    persist.byStore.private = [ ".cache/vim-swap" ];
    env.EDITOR = "vim";
    # git falls back to EDITOR if GIT_EDITOR is unspecified
    # env.GIT_EDITOR = "vim";
    mime.priority = 200;  # default=100 => yield to other, more specialized applications
    mime.associations."application/schema+json" = "nvim.desktop";
    mime.associations."plain/text" = "nvim.desktop";
    mime.associations."text/markdown" = "nvim.desktop";
  };
}
