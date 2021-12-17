flake: self: super:
let
  inherit (flake) inputs;
  inherit (flake.outputs.extraArgs.x86_64-linux) global; inherit (global) rootPath;
  inherit (super) lib callPackage writeShellScript;
  inherit (lib) recursiveUpdate;
  inherit (builtins) toString length head tail;
  inherit (flake.inputs) nixpkgsLatest nix-option nixpkgs;
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

  reduceJoin = items:
    if (length items) > 0 then
      (recursiveUpdate (head items) (reduceJoin (tail items)))
    else
    {};
in reduceJoin [
  super
  {
    inherit dotenv;
    inherit wrapDotenv;
    inherit (inputs.nixos-generators.packages."${super.system}") nixos-generators;

    lib = {
      inherit reduceJoin;
      jpg2png = cp ./lib/jpg2png.nix;
      maintainers = import "${nixpkgsLatest}/maintainers/maintainer-list.nix";
    };
    latest = import nixpkgsLatest {};
    p2k = cp inputs.pocket2kindle;
    redial_proxy = cp inputs.redial_proxy;
    send2kindle = cp inputs.send2kindle;
    comma = cp inputs.comma;
    wrapVSCode = args: import inputs.nix-vscode (args // {pkgs = super;});
    wrapEmacs = args: import inputs.nix-emacs (args // {pkgs = super;});
    discord = cp "${nixpkgsLatest}/pkgs/applications/networking/instant-messengers/discord/default.nix";
    dart = cp "${nixpkgsLatest}/pkgs/development/interpreters/dart/default.nix";
    hugo = cp "${nixpkgsLatest}/pkgs/applications/misc/hugo/default.nix";
    flutter = (cp "${nixpkgsLatest}/pkgs/development/compilers/flutter/default.nix").stable;
    tor-browser-bundle-bin = (cp "${nixpkgsLatest}/pkgs/applications/networking/browsers/tor-browser-bundle-bin/default.nix");
    obsidian = super.callPackage "${nixpkgsLatest}/pkgs/applications/misc/obsidian/default.nix" {
      # electron_13 = super.electron_12;
    };
    ventoy-bin = cp "${nixpkgsLatest}/pkgs/tools/cd-dvd/ventoy-bin/default.nix";
    c4me = cp ./packages/c4me;
    encore = cp ./packages/encore.nix;
    xplr = cp ./packages/xplr.nix;
    personal-utils = cp ./packages/personal-utils.nix;
    nixwrap = cp ./packages/nixwrap.nix;
    nix-option = callPackage "${nix-option}" {
      nixos-option = (callPackage "${nixpkgs}/nixos/modules/installer/tools/nixos-option" {}).overrideAttrs (attrs: attrs // {
        meta = attrs.meta // {
          platforms = lib.platforms.all;
        };
      });
    };
    wineApps = {
      wine7zip = cp ./packages/wineApps/7zip.nix;
      cs_extreme = cp ./packages/wineApps/cs_extreme.nix;
      dead_space = cp ./packages/wineApps/dead_space.nix;
      gta_sa = cp ./packages/wineApps/gta_sa.nix;
      among_us = cp ./packages/wineApps/among_us.nix;
      ets2 = cp ./packages/wineApps/ets2.nix;
      mspaint = cp ./packages/wineApps/mspaint.nix;
      pinball = cp ./packages/wineApps/pinball.nix;
      sosim = cp ./packages/wineApps/sosim.nix;
      tora = cp ./packages/wineApps/tora.nix;
      nfsu2 = cp ./packages/wineApps/nfsu2.nix;
      flatout2 = cp ./packages/wineApps/flatout2.nix;
      watchdogs2 = cp ./packages/wineApps/watchdogs2.nix;
      rimworld = cp ./packages/wineApps/rimworld.nix;
    };
    fhsctl = cp ./packages/fhsctl.nix;
    comby = cp ./packages/comby.nix;
    custom = {
      ncdu = cp ./packages/custom/ncdu.nix;
      neovim = cp ./packages/custom/neovim;
      emacs = cp ./packages/custom/emacs;
      rofi = cp ./packages/custom/rofi.nix;
      tixati = cp ./packages/custom/tixati.nix;
      vscode = cp ./packages/custom/vscode;
      send2kindle = cp ./packages/custom/send2kindle.nix;
      retroarch = cp ./packages/custom/retroarch.nix;
      loader = cp ./packages/custom/loader/default.nix;
      polybar = cp ./packages/custom/polybar.nix;
    };
    minecraft = cp ./packages/minecraft.nix;
    pkg = cp ./packages/pkg.nix;
    pipedream-cli = cp ./packages/pipedream-cli.nix;
    stremio = cp ./packages/stremio.nix;
    wrapWine = cp ./packages/wrapWine.nix;
    preload = cp ./packages/preload.nix;
    # python3Packages = cp ./packages/python3Packages.nix;
    nodePackages = cp ./packages/node_clis/package_data/default.nix;

    nur = import flake.inputs.nur {
      inherit (super) pkgs;
      nurpkgs = super.pkgs;
    };
  }
]
