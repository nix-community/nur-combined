{ lib, sane-lib, ...}:

{
  # XDG defines things like ~/Desktop, ~/Downloads, etc.
  # these clutter the home, so i mostly don't use them.
  sane.user.fs.".config/user-dirs.dirs" = sane-lib.fs.wantedText ''
    XDG_DESKTOP_DIR="$HOME/.xdg/Desktop"
    XDG_DOCUMENTS_DIR="$HOME/dev"
    XDG_DOWNLOAD_DIR="$HOME/tmp"
    XDG_MUSIC_DIR="$HOME/Music"
    XDG_PICTURES_DIR="$HOME/Pictures"
    XDG_PUBLICSHARE_DIR="$HOME/.xdg/Public"
    XDG_TEMPLATES_DIR="$HOME/.xdg/Templates"
    XDG_VIDEOS_DIR="$HOME/Videos"
  '';

  # prevent `xdg-user-dirs-update` from overriding/updating our config
  # see <https://manpages.ubuntu.com/manpages/bionic/man5/user-dirs.conf.5.html>
  sane.user.fs.".config/user-dirs.conf" = sane-lib.fs.wantedText "enabled=False";
}
