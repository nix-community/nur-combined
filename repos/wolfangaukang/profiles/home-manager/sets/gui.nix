{ pkgs, ... }:

{
  imports = [
    # Browser settings
    ../common/chromium.nix
    ../common/firefox.nix
  ];

  home.packages = with pkgs; [
    qbittorrent 
    keepassxc
    thunderbird
    vlc
  ];
}
