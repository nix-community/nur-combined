{ infuse }:
final: prev:
infuse prev {
  # niri.__output.patches.__append = [
  #   ../patches/2.patch
  # ];
  xdg-desktop-portal-gtk.__input.gnome-desktop.__assign = null;
  xdg-desktop-portal-gtk.__input.gsettings-desktop-schemas.__assign = null;
  xdg-desktop-portal-gtk.__output.mesonFlags.__append = [ (prev.lib.mesonEnable "wallpaper" false) ];

  qt6Packages.__inputs = {
    fcitx5-with-addons.__input.libsForQt5.fcitx5-qt.__assign = null;
    fcitx5-configtool.__input.kcmSupport.__assign = false;
    fcitx5-chinese-addons = {
      __input.qtwebengine.__assign = null;
      __output.cmakeFlags.__append = [
        (prev.lib.cmakeBool "ENABLE_BROWSER" false)
      ];
    };
  };
}
