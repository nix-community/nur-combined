{ pkgs, config, lib, ... }: with lib; let
  cfg = config.programs.ncpamixer;
  allActions = [
   "switch"
   "select"
   "quit"
   "dropdown"
   "quit"
   "mute"
   "set_default"
   "volume_up"
   "volume_down"
   "volume_up"
   "volume_down"
   "move_up"
   "move_down"
   "move_up"
   "move_down"
   "page_up"
   "page_down"
   "tab_next"
   "tab_prev"
   "tab_playback"
   "tab_recording"
   "tab_output"
   "tab_input"
   "tab_config"
   "tab_playback"
   "tab_recording"
   "tab_output"
   "tab_input"
   "tab_config"
   "move_last"
   "move_first"
   "set_volume_0"
   "set_volume_10"
   "set_volume_20"
   "set_volume_30"
   "set_volume_40"
   "set_volume_50"
   "set_volume_60"
   "set_volume_70"
   "set_volume_80"
   "set_volume_90"
   "set_volume_100"
  ];
  itemToString = value:
    if isString value then ''"${value}"''
    else if value == true then "true"
    else if value == false then "false"
    else toString value;
  itemType = types.either types.str (types.either types.int types.bool);
in {
  options.programs.ncpamixer = {
    enable = mkEnableOption "ncpamixer";
    themes = mkOption {
      type = types.attrsOf (types.attrsOf itemType);
      default = { };
    };
    theme = mkOption {
      type = types.str;
      default = "default";
    };
    keybinds = mkOption {
      type = types.attrsOf (types.enum allActions);
      default = { };
    };
    extraConfig = mkOption {
      type = types.attrsOf itemType;
      default = { };
    };
  };
  config = {
    programs.ncpamixer = {
      themes = {
        default = mapAttrs (_: mkDefault) {
          static_bar = false;
          default_indicator = "♦ ";
          "bar_style.bg" = "░";
          "bar_style.fg" = "█";
          "bar_style.indicator" = "█";
          "bar_style.top" = "▁";
          "bar_style.bottom" = "▔";
          "bar_low.front" = 2;
          "bar_low.back" = 0;
          "bar_mid.front" = 3;
          "bar_mid.back" = 0;
          "bar_high.front" = 1;
          "bar_high.back" = 0;
          volume_low = 2;
          volume_mid = 3;
          volume_high = 1;
          volume_peak = 1;
          volume_indicator = -1;
          selected = 2;
          default = -1;
          border = -1;
          "dropdown.selected_text" = 0;
          "dropdown.selected" = 2;
          "dropdown.unselected" = -1;
        };
        c0r73x = mapAttrs (_: mkDefault) {
          static_bar = false;
          default_indicator = "■ ";
          "bar_style.bg" = "■";
          "bar_style.fg" = "■";
          "bar_style.indicator" = "■";
          "bar_style.top" = "";
          "bar_style.bottom" = "";
          "bar_low.front" = 0;
          "bar_low.back" = -1;
          "bar_mid.front" = 0;
          "bar_mid.back" = -1;
          "bar_high.front" = 0;
          "bar_high.back" = -1;
          volume_low = 6;
          volume_mid = 6;
          volume_high = 6;
          volume_peak = 1;
          volume_indicator = 15;
          selected = 6;
          default = -1;
          border = -1;
          "dropdown.selected_text" = 0;
          "dropdown.selected" = 6;
          "dropdown.unselected" = -1;
        };
      };
      keybinds = mapAttrs (_: mkDefault) {
        "9"    = "switch";          # tab
        "13"   = "select";          # enter
        "27"   = "quit";            # escape
        "99"   = "dropdown";        # c
        "113"  = "quit";            # q
        "109"  = "mute";            # m
        "100"  = "set_default";     # d
        "108"  = "volume_up";       # l
        "104"  = "volume_down";     # h
        "261"  = "volume_up";       # arrow right
        "260"  = "volume_down";     # arrow left
        "107"  = "move_up";         # k
        "106"  = "move_down";       # j
        "259"  = "move_up";         # arrow up
        "258"  = "move_down";       # arrow down
        "338"  = "page_up";         # page up
        "339"  = "page_down";       # page down
        "76"   = "tab_next";        # L
        "72"   = "tab_prev";        # H
        "265"  = "tab_playback";    # f1
        "266"  = "tab_recording";   # f2
        "267"  = "tab_output";      # f3
        "268"  = "tab_input";       # f4
        "269"  = "tab_config";      # f5
        "f.80" = "tab_playback";    # f1 VT100
        "f.81" = "tab_recording";   # f2 VT100
        "f.82" = "tab_output";      # f3 VT100
        "f.83" = "tab_input";       # f4 VT100
        "f.84" = "tab_config";      # f5 VT100
        "71"   = "move_last";       # G
        "103"  = "move_first";      # g
        #"48"   = "set_volume_100";  # 0
        "48"   = "set_volume_0";    # 0
        "49"   = "set_volume_10";   # 1
        "50"   = "set_volume_20";   # 2
        "51"   = "set_volume_30";   # 3
        "52"   = "set_volume_40";   # 4
        "53"   = "set_volume_50";   # 5
        "54"   = "set_volume_60";   # 6
        "55"   = "set_volume_70";   # 7
        "56"   = "set_volume_80";   # 8
        "57"   = "set_volume_90";   # 9
      };
      extraConfig = let
        themes = mapAttrsToList (themeName: theme: mapAttrs' (opt: value:
          nameValuePair "theme.${themeName}.${opt}" (mkOptionDefault value)
        ) theme) cfg.themes;
        keybinds = mapAttrs' (bind: action:
          nameValuePair "keycode.${bind}" (mkOptionDefault action)
        ) cfg.keybinds;
      in mkMerge (themes ++ [ {
        theme = mkOptionDefault cfg.theme;
      } keybinds ]);
    };
    home.packages = mkIf cfg.enable [ pkgs.ncpamixer ];
    xdg.configFile."ncpamixer.conf" = mkIf cfg.enable {
      text = concatStringsSep "\n" (mapAttrsToList (k: v:
        ''"${k}" = ${itemToString v}''
      ) cfg.extraConfig);
    };
  };
}
