{ pkgs, ... }:

{
  imports = [
    # Browser settings
    ../common/chromium.nix
    ../common/firefox.nix
    ../common/feh.nix
  ];

  home.packages = with pkgs; [
    qbittorrent 
    keepassxc
    raven-reader
    thunderbird
    vlc
  ];
}
