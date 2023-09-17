{ config, pkgs, lib, inputs, materusFlake, materusPkgs, ... }:
with materusPkgs.lib;
{
  imports = [
    ./fonts.nix
  ];

  #Single Packages
  options.materus.profile.packages.home-manager = mkPrivateVar inputs.home-manager.packages.${pkgs.system}.home-manager;
  options.materus.profile.packages.firefox = mkPrivateVar pkgs.firefox;
  
  #Package Lists
  options.materus.profile.packages.list.nixRelated = mkPrivateVar (with pkgs; [
    nix-prefetch
    nix-prefetch-scripts
    nix-prefetch-github
    nix-prefetch-docker
    nixfmt
    nix-top
    nix-tree
    nix-diff
    nix-ld
    rnix-hashes
    rnix-lsp
    nixpkgs-review
  ]);

  options.materus.profile.packages.list.desktopApps = mkPrivateVar (with pkgs; [
    barrier
    (discord.override { nss = nss_latest; withOpenASAR = true; withTTS = true;})
    tdesktop
    mpv
    ani-cli
    (pkgs.obsidian)
    spotify
    thunderbird
    keepassxc
    (aspellWithDicts (ds: with ds; [ en en-computers en-science pl ]))
    onlyoffice-bin
  ]);

  options.materus.profile.packages.list.terminalApps = mkPrivateVar (with pkgs; [
    neofetch
    ripgrep
    fd
  ]);

}

