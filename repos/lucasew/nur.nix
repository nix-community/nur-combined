{pkgs ? import <nixpkgs> {}, ...}:
{
  hmModules = {
    customRofi = ./modules/custom_rofi/home.nix;
    htop = ./modules/htop/home.nix;
    kdeconnect = ./modules/kdeconnect/home.nix;
    nixgram-service = ./modules/nixgram/home.nix;
    spotify-adskip = ./modules/spotify/home.nix;
    youtubemusic-adskip = ./modules/youtube/home.nix;
    tmux = ./modules/tmux/home.nix;
  };
  modules = {
    cachix = ./modules/cachix/system.nix;
    keybase = ./modules/keybase/system.nix;
    neovim = ./modules/neovim/system.nix;
    virt-manager = ./modules/virt-manager/system.nix;
  };
  packages = {
    a22020 = pkgs.callPackage ./modules/node_clis/package_22120.nix;
    dotenv = pkgs.callPackage ./modules/dotenv/package.nix;
    minecraft-shiginima = pkgs.callPackage ./modules/minecraft/package.nix;
    mspaint-xp = pkgs.callPackage ./modules/mspaint/package.nix;
    nixgram = pkgs.callPackage ./modules/nixgram/package.nix;
    pinball-xp = pkgs.callPackage ./modules/pinball/package.nix;
    stremio = pkgs.callPackage ./modules/stremio/package.nix;
  };
  lib = {
    fetch = import ./lib/fetch.nix;
    filter = import ./lib/filter.nix;
    image2color = import ./lib/image2color.nix;
    importAllIn = import ./lib/importAllIn.nix;
    lsName = import ./lib/lsName.nix;
    pathListIfExist = import ./lib/pathListIfExist.nix;
    systemdUserService = import ./lib/systemdUserService.nix;
    tail = import ./lib/tail.nix;
    mkNativefier = import ./lib/mkNativefier;
  };
}
