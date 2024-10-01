{ config, lib, pkgs, ... }:
let
  cfg = config.programs.fastfetch.sn0wm1x;
  enable = cfg && config.programs.fastfetch.enable;
in
{
  options.programs.fastfetch.sn0wm1x = lib.mkEnableOption "sn0wm1x fastfetch";

  config = lib.mkIf enable {
    programs.fastfetch.settings =
      let
        logo = pkgs.fetchurl {
          url = "https://github.com/sn0wm1x.png";
          hash = "sha256-7gAf++UN5o7+aP8jLno46zaEtni7vwNBrxD1pDkcA3A=";
        };
      in
      {
        logo = {
          type = "kitty-direct";
          source = "${logo}";
        };
        # https://github.com/fastfetch-cli/fastfetch/blob/dev/presets/screenfetch.jsonc
        modules = [
          "title"
          {
            "type" = "os";
            "format" = "SN0WM1X (Nix) OS ({11}, {12})";
          }
          "kernel"
          "uptime"
          {
            "type" = "packages";
            "format" = "{all}";
          }
          "shell"
          {
            "type" = "display";
            "key" = "Resolution";
            "compactType" = "original";
          }
          "de"
          "wm"
          "wmtheme"
          {
            "type" = "terminalfont";
            "key" = "font";
          }
          {
            "type" = "disk";
            "folders" = "/";
            "key" = "Disk";
          }
          "cpu"
          "gpu"
          {
            "type" = "memory";
            "key" = "RAM";
          }
        ];
      };
  };
}
