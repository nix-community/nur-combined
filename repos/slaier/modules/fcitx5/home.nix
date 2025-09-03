{
  xdg.dataFile = {
    "fcitx5/rime/default.custom.yaml".text = builtins.toJSON {
      patch = {
        schema_list = [ ({ schema = "wanxiang"; }) ];
        "menu/page_size" = 9;
        "ascii_composer/good_old_caps_lock" = true;
        "ascii_composer/switch_key" = {
          "Caps_Lock" = "noop";
          "Shift_L" = "commit_code";
          "Shift_R" = "commit_code";
          "Control_L" = "noop";
          "Control_R" = "noop";
        };
        "switcher/hotkeys" = [ "F4" ];
        "switcher/save_options" = [
          "full_shape"
          "ascii_punct"
          "chinese_english"
          "emoji"
          "tone_hint"
          "search_single_char"
        ];
        "switcher/fold_options" = false;
        "switcher/abbreviate_options" = false;
      };
    };

    "fcitx5/rime/wanxiang.custom.yaml".text = builtins.toJSON {
      patch = {
        "switches" = [
          {
            name = "ascii_mode";
            reset = 1;
          }
          {
            name = "super_tips";
            reset = 0;
          }
        ];
      };
    };
  };
}
