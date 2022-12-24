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

    # custom things
    custom_neovim = p ./pkgs/custom/neovim;
    custom_rofi = p ./pkgs/custom/rofi.nix;

    # utils
    pkg = p ./pkgs/pkg.nix;
    c4me = p ./pkgs/c4me;
    fhsctl = p ./pkgs/fhsctl.nix;
  };
  lib = {
    filter = import ./lib/filter.nix;
    image2color = import ./lib/image2color.nix;
    importAllIn = import ./lib/importAllIn.nix;
    lsName = import ./lib/lsName.nix;
    pathListIfExist = import ./lib/pathListIfExist.nix;
  };
}
