{
  config,
  lib,
  pkgs,
  ...
}:
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
        # Modified from Omarchy
        # https://github.com/basecamp/omarchy/blob/2df8c5f7e0a2aafb8c9aacb322408d2ed7682ea5/config/fastfetch/config.jsonc
        json = builtins.fromJSON (builtins.readFile ../../../assets/fastfetch.json);
      in
      json
      // {
        logo = {
          type = "kitty-direct";
          source = "${logo}";
          padding = {
            top = 4;
            right = 2;
            left = 2;
          };
        };
      };
  };
}
