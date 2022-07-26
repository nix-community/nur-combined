{pkgs ? import <nixpkgs> {}, ...}:
let
  p = path: pkgs.callPackage path {};
in
{
  hmModules = {
    tmux = ./modules/tmux/home.nix;
    wallpaper = ./modules/wallpaper/home.nix;
  };
  modules = {
    cachix = ./modules/cachix/system.nix;
  };
  packages = {
    # wine packages
    wrapWine = p ./pkgs/wrapWine.nix;
    mspaint = p ./pkgs/wineApps/mspaint.nix;
    pinball = p ./pkgs/wineApps/pinball.nix;
    sosim = p ./pkgs/wineApps/sosim.nix;
    tora = p ./pkgs/wineApps/tora.nix;
    wine7zip = p ./pkgs/wineApps/7zip.nix;

    # custom things
    custom_neovim = p ./modules/neovim/package.nix;
    custom_rofi = p ./pkgs/custom_rofi.nix;
    tlauncher = p ./pkgs/tlauncher.nix;
    stremio = p ./pkgs/stremio.nix;

    # webapp stuff
    webapp = p ./pkgs/webapp.nix;
    webapps = p ./pkgs/chromeapps.nix;

    # utils
    pkg = p ./pkgs/pkg.nix;
    c4me = p ./pkgs/c4me/default.nix;
    fhsctl = p ./pkgs/fhsctl.nix;
  };
  lib = {
    filter = import ./lib/filter.nix;
    image2color = import ./lib/image2color.nix;
    importAllIn = import ./lib/importAllIn.nix;
    lsName = import ./lib/lsName.nix;
    pathListIfExist = import ./lib/pathListIfExist.nix;
    systemdUserService = import ./lib/systemdUserService.nix;
    tail = import ./lib/tail.nix;
    mkNativefier = import ./lib/mkNativefier;
    flake = import ./lib/flake;
  };
}
