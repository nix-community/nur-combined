{pkgs ? import <nixpkgs> {}, ...}:
let
  p = path: pkgs.callPackage path {};
in
{
  hmModules = {
    spotify-adskip = ./modules/spotify/home.nix;
    youtube-adskip = ./modules/youtube/home.nix;
    tmux = ./modules/tmux/home.nix;
    wallpaper = ./modules/wallpaper/home.nix;
  };
  modules = {
    cachix = ./modules/cachix/system.nix;
  };
  packages = {
    custom_rofi = p ./packages/custom_rofi.nix;
    shiginima = p ./packages/minecraft.nix;
    mspaint = p ./packages/mspaint.nix;
    custom_neovim = p ./modules/neovim/package.nix;
    pinball = p ./packages/pinball.nix;
    stremio = p ./packages/stremio.nix;
    peazip = p ./packages/peazip.nix;
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
