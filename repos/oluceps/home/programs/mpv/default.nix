{ pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    scripts = [ pkgs.mpvScripts.uosc ];
    config = {
      vo = "gpu-next";
      hwdec = "auto-safe";
      gpu-api = "vulkan";
      gpu-context = "waylandvk";
    };
    bindings = {
      "r" = "cycle_values video-rotate 90 180 270 0";
    };
  };
}
