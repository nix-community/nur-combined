{
  xdg.dataFile = {
    "fcitx5/rime/default.custom.yaml".text = builtins.toJSON {
      patch = {
        schema_list = [ { schema = "rime_ice"; } ];
        ascii_composer.switch_key = {
          Shift_L = "commit_code";
          Shift_R = "commit_code";
        };
      };
    };
  };
}
