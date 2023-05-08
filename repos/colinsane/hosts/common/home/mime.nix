{ config, sane-lib, ...}:

let
  www = config.sane.programs.web-browser.config.browser.desktop;
  pdf = "org.gnome.Evince.desktop";
  md = "obsidian.desktop";
  thumb = "org.gnome.gThumb.desktop";
  video = "vlc.desktop";
  # audio = "mpv.desktop";
  audio = "vlc.desktop";
in
{

  # the xdg mime type for a file can be found with:
  # - `xdg-mime query filetype path/to/thing.ext`
  # we can have single associations or a list of associations.
  # there's also options to *remove* [non-default] associations from specific apps
  xdg.mime.enable = true;
  xdg.mime.defaultApplications = {
    # AUDIO
    "audio/flac" = audio;
    "audio/mpeg" = audio;
    "audio/x-vorbis+ogg" = audio;
    # IMAGES
    "image/heif" = thumb;  # apple codec
    "image/png" = thumb;
    "image/jpeg" = thumb;
    # VIDEO
    "video/mp4" = video;
    "video/quicktime" = video;
    "video/x-matroska" = video;
    # HTML
    "text/html" = www;
    "x-scheme-handler/http" = www;
    "x-scheme-handler/https" = www;
    "x-scheme-handler/about" = www;
    "x-scheme-handler/unknown" = www;
    # RICH-TEXT DOCUMENTS
    "application/pdf" = pdf;
    "text/markdown" = md;
  };
}
