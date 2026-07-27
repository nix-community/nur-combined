{ pkgs, ... }:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      (fcitx5-rime.override {
        rimeDataPkgs = [ (pkgs.my.rime-ice.override { enableUnihan = true; }) ];
      })
    ];
  };
}
