{ config, pkgs, ... }: {
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.enableRimeData = true;
    fcitx5.addons = with pkgs; with config.nur.repos.xddxdd; [
      fcitx5-chinese-addons
      fcitx5-gtk
      fcitx5-rime
      libsForQt5.fcitx5-qt
      rime-aurora-pinyin
      rime-data
      rime-dict
      rime-moegirl
      rime-zhwiki
    ];
  };
}
