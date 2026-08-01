{
  pkgs,
  hostConfig,
  lib,
  ...
}:

lib.optionalAttrs hostConfig.isGraphical {
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      modernz
      (mpv-cheatsheet-ng.overrideAttrs (_: {
        postInstall = ''
          substituteInPlace "$out/share/mpv/scripts/cheatsheet.lua" \
            --replace-fail 'font_size = 8,' 'font_size = 5.5,' \
            --replace-fail 'usage_font_size = 6,' 'usage_font_size = 5,'
        '';
      }))
    ];
    config = {
      osc = "no";
    };
    scriptOpts = {
      stats = {
        font_size = 12;
      };
      modernz = {
        window_controls = "no";
        speed_mbtn_left_command = "osd-msg add speed 0.1";
        speed_mbtn_right_command = "osd-msg set speed 1";
        speed_wheel_up_command = "osd-msg add speed 0.1";
        speed_wheel_down_command = "osd-msg add speed -0.1";
        loop_button = "no";
        screenshot_button = "no";
        ontop_button = "no";
        seekbarfg_color = "#DCDFE4";
        seekbarbg_color = "#5A6374";
        seek_handle_color = "#DCDFE4";
        seek_handle_border_color = "";
        nibble_color = "#DCDFE4";
        hover_effect_color = "#DCDFE4";
        playpause_size = 18;
        midbuttons_size = 16;
        sidebuttons_size = 14;
        title_font_size = 18;
        time_font_size = 12;
        tooltip_font_size = 10;
        speed_font_size = 12;
        hover_effect = "size,color";
        slider_hover_size = 110;
        seek_handle_size = 0.55;
      };
    };
  };
}
