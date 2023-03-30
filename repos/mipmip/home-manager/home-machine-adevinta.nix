{ config, pkgs, ... }:

{
  imports = [
    ./home-base-macos.nix

    ./files-secondbrain
    ./files-i-am-desktop

    ./conf-cli/zsh_macos_adevinta.nix

    /Users/pim.snel/nixos/private/adevinta/home-manager/files-main
  ];

  home.username = "pim.snel";
  home.homeDirectory = "/Users/pim.snel";
}
