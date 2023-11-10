{ pkgs, ... }:

{
  imports = [
    ./aerc.nix
    ./alacritty.nix
    ./assorted.nix
    ./bemenu.nix
    ./brave.nix
    ./calls.nix
    ./cantata.nix
    ./chatty.nix
    ./conky
    ./cozy.nix
    ./dialect.nix
    ./dino.nix
    ./element-desktop.nix
    ./epiphany.nix
    ./evince.nix
    ./feedbackd.nix
    ./firefox.nix
    ./flare-signal.nix
    ./fontconfig.nix
    ./fractal.nix
    ./fwupd.nix
    ./g4music.nix
    ./gajim.nix
    ./geary.nix
    ./git.nix
    ./gnome-feeds.nix
    ./gnome-keyring.nix
    ./gnome-weather.nix
    ./gpodder.nix
    ./gthumb.nix
    ./helix.nix
    ./imagemagick.nix
    ./jellyfin-media-player.nix
    ./komikku.nix
    ./koreader
    ./libreoffice.nix
    ./lemoa.nix
    ./mako.nix
    ./megapixels.nix
    ./mepo.nix
    ./mopidy.nix
    ./mpv.nix
    ./msmtp.nix
    ./neovim.nix
    ./newsflash.nix
    ./nheko.nix
    ./nix-index.nix
    ./ntfy-sh.nix
    ./obsidian.nix
    ./offlineimap.nix
    ./playerctl.nix
    ./rhythmbox.nix
    ./ripgrep.nix
    ./sfeed.nix
    ./splatmoji.nix
    ./spot.nix
    ./spotify.nix
    ./steam.nix
    ./stepmania.nix
    ./sublime-music.nix
    ./swaynotificationcenter.nix
    ./tangram.nix
    ./tor-browser-bundle-bin.nix
    ./tuba.nix
    ./vlc.nix
    ./wike.nix
    ./wireshark.nix
    ./xarchiver.nix
    ./zeal.nix
    ./zsh
  ];

  config = {
    # XXX: this might not be necessary. try removing this and cacert.unbundled (servo)?
    environment.etc."ssl/certs".source = "${pkgs.cacert.unbundled}/etc/ssl/certs/*";

  };
}
