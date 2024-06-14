{ pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      autoload
      chapterskip
      mpv-cheatsheet
      thumbfast
      uosc
    ];
    config = {
      profile = "high-quality";
      cscale = "catmull_rom";
      deband = true;
      blend-subtitles = "video";
      video-sync = "display-resample";
      interpolation = true;
      tscale = "oversample";
      sub-auto = "fuzzy";
      fullscreen = true;
      hwdec = "auto-safe";
      osd-bar = false;
      border = false;
    };
  };
}
