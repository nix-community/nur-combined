{ pkgs, ... }:

{
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      uosc
      vr-reversal
      mpris
    ];
    config = {
      profile = "gpu-hq";
      hwdec = "auto-safe";
      gpu-context = "wayland";
      hwdec-codecs = "vaapi";
      blend-subtitles = "video";
      sub-auto = "fuzzy";
      interpolation = "yes";
    };
  };
}
