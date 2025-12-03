{ ... }:

{
  # XDG defines things like ~/Desktop, ~/Downloads, etc.
  # these clutter the home, so i mostly don't use them.
  # note that several of these are not actually standardized anywhere.
  # some are even non-conventional, like:
  # - XDG_PHOTOS_DIR: only works because i patch e.g. megapixels
  sane.user.fs.".config/user-dirs.dirs".symlink.text = ''
    XDG_CACHE_DIR="$HOME/.cache"
    XDG_DESKTOP_DIR="$HOME/.xdg/Desktop"
    XDG_DOCUMENTS_DIR="$HOME/dev"
    XDG_DOWNLOAD_DIR="$HOME/tmp"
    XDG_MUSIC_DIR="$HOME/Music"
    XDG_PHOTOS_DIR="$HOME/Pictures/Photos"
    XDG_PICTURES_DIR="$HOME/Pictures"
    XDG_PUBLICSHARE_DIR="$HOME/.xdg/Public"
    XDG_SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
    XDG_TEMPLATES_DIR="$HOME/.xdg/Templates"
    XDG_VIDEOS_DIR="$HOME/Videos"
  '';

  # prevent `xdg-user-dirs-update` from overriding/updating our config
  # see <https://manpages.ubuntu.com/manpages/bionic/man5/user-dirs.conf.5.html>
  sane.user.fs.".config/user-dirs.conf".symlink.text = "enabled=False";

  sane.user.fs.".config/environment.d/30-user-dirs.conf".symlink.target = "../user-dirs.dirs";
}
