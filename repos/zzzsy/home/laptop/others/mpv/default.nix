{ pkgs, ... }:

{
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [ uosc ];
    config = {
      profile = "gpu-hq";
      hwdec = "auto-safe";
      hwdec-codecs = "vaapi";
      blend-subtitles = "video";
      sub-auto = "fuzzy";
    };
  };
}
