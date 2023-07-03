{ pkgs, ... }:

{
  imports = [
    ./aerc.nix
    ./assorted.nix
    ./cozy.nix
    ./epiphany.nix
    ./git.nix
    ./gnome-feeds.nix
    ./gpodder.nix
    ./gthumb.nix
    ./imagemagick.nix
    ./jellyfin-media-player.nix
    ./kitty
    ./komikku.nix
    ./koreader
    ./libreoffice.nix
    ./lemoa.nix
    ./mepo.nix
    ./mpv.nix
    ./msmtp.nix
    ./neovim.nix
    ./newsflash.nix
    ./nix-index.nix
    ./offlineimap.nix
    ./ripgrep.nix
    ./sfeed.nix
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
