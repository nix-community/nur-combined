{ pkgs, ... }: {
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-chinese-addons
      fcitx5-gtk
      libsForQt5.fcitx5-qt
      (fcitx5-rime.override {
        rimeDataPkgs = with nur.repos.xddxdd; [
          rime-aurora-pinyin
          rime-data
          rime-dict
          rime-moegirl
          rime-zhwiki
        ];
      })
    ];
  };
}
