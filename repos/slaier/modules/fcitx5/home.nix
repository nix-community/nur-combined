{
  xdg.dataFile = {
    "fcitx5/rime/default.custom.yaml".text = builtins.toJSON {
      patch = {
        schema_list = [ ({ schema = "rime_ice"; }) ];
      };
    };
  };
}
