{
  lib,
  hostConfig,
  ...
}:
{
  programs.kitty = lib.optionalAttrs (hostConfig.isGraphical && hostConfig.isLinux) {
    enable = true;
    font = {
      name = "caskaydia-cove";
      # size = ;
    };
    # extraConfig = "";
    settings = {
      window_border_width = "1pt";
      window_margin_width = "1";
      window_padding_width = "1";

      # C O L O R S
      foreground = "#DCDFE4";
      background = "#282C34";
      background_opacity = "0.72";

      selection_background = "#DCDFE4";

      # White
      color7 = "#DCDFE4";
      color15 = "#DCDFE4";

      # Black
      color0 = "#5A6374";
      color8 = "#282C34";

      # Red
      color1 = "#E06C75";
      color9 = "#E06C75";

      # Green
      color2 = "#98C379";
      color10 = "#98C379";

      # Yellow
      color3 = "#E5C07B";
      color11 = "#E5C07B";

      # Blue
      color4 = "#61AFEF";
      color12 = "#61AFEF";

      # Purple
      color5 = "#C678DD";
      color13 = "#C678DD";

      # Cyan
      color6 = "#56B6C2";
      color14 = "#56B6C2";
    };
  };
}
