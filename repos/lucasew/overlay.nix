flake: final: prev:
let
  inherit (flake) inputs;
  inherit (flake.outputs) global bumpkin;
  inherit (global) rootPath;
  inherit (prev) lib callPackage writeShellScript;
  inherit (lib) recursiveUpdate;
  inherit (builtins) toString length head tail;
in
let
  cp = f: (callPackage f) {};
in {
  inherit flake;
  inherit bumpkin;

  lib = prev.lib.extend (final: prev: with final; with inputs.nixpkgs-lib.lib; {
    jpg2png = cp ./lib/jpg2png.nix;
    buildDockerEnv = cp ./lib/buildDockerEnv.nix;
    climod = cp bumpkin.unpackedInputs.climod;
  });

  ctl = cp ./pkgs/ctl;
  c4me = cp ./pkgs/c4me;
  personal-utils = cp ./pkgs/personal-utils.nix;
  fhsctl = cp ./pkgs/fhsctl.nix;
  comby = cp ./pkgs/comby.nix;
  pkg = cp ./pkgs/pkg.nix;
  wrapWine = cp ./pkgs/wrapWine.nix;

  dotenv = cp bumpkin.unpackedInputs.dotenv;
  # bumpkin = cp inputs.bumpkin;
  nbr = import "${bumpkin.unpackedInputs.nbr}" { pkgs = final; };
  appimage-wrap = final.nbr.appimage-wrap;

  p2k = cp bumpkin.unpackedInputs.pocket2kindle;
  pytorrentsearch = cp bumpkin.unpackedInputs.pytorrentsearch;
  redial_proxy = cp bumpkin.unpackedInputs.redial_proxy;
  send2kindle = cp bumpkin.unpackedInputs.send2kindle;
  wrapVSCode = args: import bumpkin.unpackedInputs.nix-vscode (args // {pkgs = prev;});
  wrapEmacs = args: import bumpkin.unpackedInputs.nix-emacs (args // {pkgs = prev;});

  nix-option = callPackage "${bumpkin.unpackedInputs.nix-option}" {
    nixos-option = (callPackage "${bumpkin.unpackedInputs.nixpkgs.unstable}/nixos/modules/installer/tools/nixos-option" {}).overrideAttrs (attrs: attrs // {
      meta = attrs.meta // {
        platforms = lib.platforms.all;
      };
    });
  };
  nur = import bumpkin.unpackedInputs.nur {
    inherit (prev) pkgs;
    nurpkgs = prev.pkgs;
  };

  wineApps = {
    cs_extreme = cp ./pkgs/wineApps/cs_extreme.nix;
    dead_space = cp ./pkgs/wineApps/dead_space.nix;
    gta_sa = cp ./pkgs/wineApps/gta_sa.nix;
    among_us = cp ./pkgs/wineApps/among_us.nix;
    ets2 = cp ./pkgs/wineApps/ets2.nix;
    mspaint = cp ./pkgs/wineApps/mspaint.nix;
    pinball = cp ./pkgs/wineApps/pinball.nix;
    sosim = cp ./pkgs/wineApps/sosim.nix;
    tora = cp ./pkgs/wineApps/tora.nix;
    nfsu2 = cp ./pkgs/wineApps/nfsu2.nix;
    flatout2 = cp ./pkgs/wineApps/flatout2.nix;
    watchdogs2 = cp ./pkgs/wineApps/watchdogs2.nix;
    rimworld = cp ./pkgs/wineApps/rimworld.nix;
    skyrim = cp ./pkgs/wineApps/skyrim.nix;
  };
  custom = rec {
    colorpipe = cp ./pkgs/colorpipe.nix;
    ncdu = cp ./pkgs/custom/ncdu.nix;
    neovim = cp ./pkgs/custom/neovim;
    emacs = cp ./pkgs/custom/emacs;
    firefox = cp ./pkgs/custom/firefox;
    tixati = cp ./pkgs/custom/tixati.nix;
    vscode = cp ./pkgs/custom/vscode;
    rofi = cp ./pkgs/custom/rofi.nix;
    send2kindle = cp ./pkgs/custom/send2kindle.nix;
    retroarch = cp ./pkgs/custom/retroarch.nix;
    loader = cp ./pkgs/custom/loader/default.nix;
    polybar = cp ./pkgs/custom/polybar.nix;
    colors-lib-contrib = bumpkin.flakedInputs.nix-colors.lib-contrib { pkgs = prev; };
    # wallpaper = ./wall.jpg;
    wallpaper = colors-lib-contrib.nixWallpaperFromScheme {
      scheme = colors;
      width = 1366;
      height = 768;
      logoScale = 2;
    };
    inherit (flake.outputs) colors;
  };
  
  intel-ocl = prev.intel-ocl.overrideAttrs (old: {
    src = prev.fetchzip {
      url = "https://github.com/lucasew/nixcfg/releases/download/debureaucracyzzz/SRB5.0_linux64.zip";
      sha256 = "sha256-4qaX7wTqxKSrRWeQv1Zrs6eTT0fKJ6g9QBFocugwd2E=";
      stripRoot = false;
    };
  });
}
