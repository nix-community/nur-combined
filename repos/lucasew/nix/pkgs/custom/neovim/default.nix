{
  pkgs,
  flake,
  lib,
  python3,
  colors ? null,
  ...
}:
let
  inherit (builtins) toString readFile trace;
  inherit (flake) inputs;
  inherit (pkgs)
    fetchFromGitHub
    vimPlugins
    fetchurl
    callPackage
    fetchzip
    ;
  inherit (pkgs.vimUtils) buildVimPlugin buildVimPluginFrom2Nix;

  pluginIonideVim = buildVimPlugin {
    name = "ionide-vim";
    src = fetchFromGitHub {
      owner = "ionide";
      repo = "ionide-vim";
      rev = "0b688cccdb80598e09cd24cd3537145f8633e051";
      sha256 = "sha256-/CizU/ZeyjN7MM0dMoSAd3nFtOth5U0cUZt0bV0wjIw=";
    };
    dontBuild = true;
    postInstall =
      let
        zip = fetchurl {
          url = "https://github.com/fsharp/FsAutoComplete/releases/download/0.47.2/fsautocomplete.netcore.zip";
          sha256 = "1hf6znwpli8mr9mn0ifx6y0v60mzz76k5md7i80gxc5q8mh636l7";
        };
      in
      ''
        ${pkgs.unzip}/bin/unzip -o -d $out/share/vim-plugins/ionide-vim/fsac ${zip}
        chmod 555 $out/share/vim-plugins/ionide-vim/fsac -R
      '';
  };
  fennel-nvim = buildVimPlugin {
    name = "fennel-nvim";
    patchPhase = ''
      substituteInPlace doc/fennel-nvim.txt --replace '*fennel.path*' 'fennel.path'
    '';
    src = fetchFromGitHub {
      owner = "jaawerth";
      repo = "fennel-nvim";
      rev = "4792d26e0c98de5193f2c872dc57401dc8913479";
      sha256 = "sha256-KpkLmd9GkpVtXS6xo9YEoeomoklp2DGC+X3PRAWVgGw=";
    };
  };
in
pkgs.neovim.override {
  withPython3 = true;
  withRuby = false;
  configure = {
    packages.plugins.start =
      with vimPlugins;
      [
        # utils
        coq_nvim
        coq-artifacts
        echodoc
        emmet-vim
        fennel-nvim
        nvim-lspconfig
        vim-commentary
        vim-fetch # support for stacktrace paths
        telescope-nvim
        yescapsquit-vim
        trouble-nvim
        vim-better-whitespace

        # language specific
        dart-vim-plugin
        fennel-vim
        plantuml-syntax
        polyglot
        # pluginIonideVim
        vim-nix
        vim-terraform
        vim-svelte

        # deps
        plenary-nvim # dep of telescope
        popup-nvim # dep of telescope

        # themes
        embark-vim
        onedark-vim
        starrynight
        vim-paper
        preto

        nvim-web-devicons
      ]
      ++ (lib.optional (colors != null) (buildVimPlugin {
        name = "nix-colors";
        src =
          let
          in
          pkgs.custom.colors-lib-contrib.vimThemeFromScheme { scheme = colors; };
      }));

    customRC = ''
      ${if colors != null then ''let g:nix_colors_theme="nix-${colors.slug}"'' else ""}
      ${readFile ./rc.vim}
      lua << EOF
        package.preload.fennel = function () return dofile('${pkgs.fennel}/share/lua/5.2/fennel.lua') end
        local fnl = require('fennel-nvim')
        fnl.dofile('${./init.fnl}')
      EOF
    '';
  };
}
