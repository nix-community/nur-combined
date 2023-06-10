{ pkgs, ... }:

{
  imports = [
    ./aerc.nix
    ./assorted.nix
    ./git.nix
    ./gnome-feeds.nix
    ./gpodder.nix
    ./imagemagick.nix
    ./jellyfin-media-player.nix
    ./kitty
    ./libreoffice.nix
    ./mpv.nix
    ./neovim.nix
    ./newsflash.nix
    ./offlineimap.nix
    ./ripgrep.nix
    ./splatmoji.nix
    ./steam.nix
    ./sublime-music.nix
    ./vlc.nix
    ./web-browser.nix
    ./wireshark.nix
    ./zeal.nix
    ./zsh
  ];

  config = {
    # XXX: this might not be necessary. try removing this and cacert.unbundled (servo)?
    environment.etc."ssl/certs".source = "${pkgs.cacert.unbundled}/etc/ssl/certs/*";

  };
}
