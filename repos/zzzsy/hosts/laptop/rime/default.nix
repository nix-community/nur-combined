{ pkgs, ... }:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      (fcitx5-rime.override {
        librime =
          (pkgs.librime.overrideAttrs (old: {
            buildInputs = old.buildInputs ++ [ pkgs.lua5_4 ];
          })).override
            { plugins = with pkgs.my; [ librime-lua ]; };
        rimeDataPkgs = [ (pkgs.my.rime-ice.override { enableUnihan = true; }) ];
      })
    ];
  };
}
