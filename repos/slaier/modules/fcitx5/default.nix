{ pkgs, ... }: {
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-gtk
        (fcitx5-rime.override {
          rimeDataPkgs = with nur.repos.xddxdd; [
            rime-aurora-pinyin
            rime-custom-pinyin-dictionary
            rime-data
            rime-dict
            rime-ice
            rime-moegirl
            rime-zhwiki
          ];
        })
      ];
      ignoreUserConfig = true;
      settings = {
        inputMethod = {
          GroupOrder."0" = "Default";
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "rime";
          };
          "Groups/0/Items/0".Name = "rime";
        };
      };
    };
  };
}
