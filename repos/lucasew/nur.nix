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
    wrapWine = p ./packages/wrapWine.nix;
    mspaint = p ./packages/wineApps/mspaint.nix;
    pinball = p ./packages/wineApps/pinball.nix;
    sosim = p ./packages/wineApps/sosim.nix;
    tora = p ./packages/wineApps/tora.nix;
    wine7zip = p ./packages/wineApps/7zip.nix;

    # custom things
    custom_neovim = p ./modules/neovim/package.nix;
    custom_rofi = p ./packages/custom_rofi.nix;
    peazip = p ./packages/peazip.nix;
    tlauncher = p ./packages/tlauncher.nix;
    stremio = p ./packages/stremio.nix;

    # webapp stuff
    webapp = p ./packages/webapp.nix;
    webapps = p ./packages/chromeapps.nix;

    # utils
    pkg = p ./packages/pkg.nix;
    c4me = p ./packages/c4me/default.nix;
    fhsctl = p ./packages/fhsctl.nix;
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
