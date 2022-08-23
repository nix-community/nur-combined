flake: final: prev:
let
  inherit (flake) inputs;
  inherit (flake.outputs) global;
  inherit (global) rootPath;
  inherit (prev) lib callPackage writeShellScript;
  inherit (lib) recursiveUpdate;
  inherit (builtins) toString length head tail;
  inherit (flake.inputs) nix-option nixpkgs;
in
let
  cp = f: (callPackage f) {};
  dotenv = cp inputs.dotenv;
  wrapDotenv = (file: script:
    let
      dotenvFile = ((toString rootPath) + "/secrets/" + (toString file));
      command = writeShellScript "dotenv-wrapper" script;
    in ''
      ${dotenv}/bin/dotenv "@${toString dotenvFile}" -- ${command} "$@"
    '');

in {
  inherit flake;

  inherit dotenv;
  inherit wrapDotenv;
  inherit (inputs.nixos-generators.packages."${prev.system}") nixos-generators;
  inherit (flake.inputs.packages.comma);

  lib = prev.lib // {
    jpg2png = cp ./lib/jpg2png.nix;
    buildDockerEnv = cp ./lib/buildDockerEnv.nix;
    mkWindowsApp = inputs.erosanix.lib."${prev.system}".mkWindowsApp;
  };
  appimage-wrap = cp ./pkgs/appimage-wrap;
  p2k = cp inputs.pocket2kindle;
  redial_proxy = cp inputs.redial_proxy;
  send2kindle = cp inputs.send2kindle;
  wrapVSCode = args: import inputs.nix-vscode (args // {pkgs = prev;});
  wrapEmacs = args: import inputs.nix-emacs (args // {pkgs = prev;});
  c4me = cp ./pkgs/c4me;
  encore = cp ./pkgs/encore.nix;
  weston-run = cp ./pkgs/weston-desktop.nix;
  xplr = cp ./pkgs/xplr.nix;
  personal-utils = cp ./pkgs/personal-utils.nix;
  nixwrap = cp ./pkgs/nixwrap.nix;
  nix-option = callPackage "${nix-option}" {
    nixos-option = (callPackage "${nixpkgs}/nixos/modules/installer/tools/nixos-option" {}).overrideAttrs (attrs: attrs // {
      meta = attrs.meta // {
        platforms = lib.platforms.all;
      };
    });
  };
  wineApps = {
    wine7zip = cp ./pkgs/wineApps/7zip.nix;
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
  fhsctl = cp ./pkgs/fhsctl.nix;
  comby = cp ./pkgs/comby.nix;
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
    colors-lib-contrib = inputs.nix-colors.lib-contrib { pkgs = prev; };
    # wallpaper = ./wall.jpg;
    wallpaper = colors-lib-contrib.nixWallpaperFromScheme {
      scheme = colors;
      width = 1366;
      height = 768;
      logoScale = 2;
    };
    inherit (flake.outputs) colors;
  };
  Geographical-Adventures = cp ./pkgs/Geographical-Adventures.nix;
  t-launcher = cp ./pkgs/tlauncher.nix;
  pkg = cp ./pkgs/pkg.nix;
  pipedream-cli = cp ./pkgs/pipedream-cli.nix;
  wrapWine = cp ./pkgs/wrapWine.nix;
  wonderland-engine = cp ./pkgs/wonderland-engine.nix;
  preload = cp ./pkgs/preload.nix;
  nodePackages = prev.nodePackages // (cp ./pkgs/node_clis/package_data/default.nix);
  null = prev.stdenv.mkDerivation { dontUnpack = true; installPhase = "mkdir $out"; };
  speech-recognition = cp ./pkgs/speech-recognition.nix;
  nur = import flake.inputs.nur {
    inherit (prev) pkgs;
    nurpkgs = prev.pkgs;
  };
  discord = prev.discord.overrideAttrs (old: rec {
    version = "0.0.19";
    src = prev.fetchurl {
      url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
      sha256 = "1403vdc7p6a8mhr114brfp4dqvikaj5s71wrx20ca5y6srsv5x0r";
    };
  });
  intel-ocl = prev.intel-ocl.overrideAttrs (old: {
    src = prev.fetchzip {
      url = "https://github.com/lucasew/nixcfg/releases/download/debureaucracyzzz/SRB5.0_linux64.zip";
      sha256 = "sha256-4qaX7wTqxKSrRWeQv1Zrs6eTT0fKJ6g9QBFocugwd2E=";
      stripRoot = false;
    };
  });
}
