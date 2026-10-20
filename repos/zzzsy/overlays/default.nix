{ infuse }:
final: prev:
infuse prev {
  # niri.__output.patches.__append = [
  #   ../patches/1.patch
  # ];

  sing-box.__output = {
    version.__assign = "1.15.0-alpha.12";
    src.__assign = final.fetchFromGitHub {
      owner = "SagerNet";
      repo = "sing-box";
      tag = "v1.15.0-alpha.12";
      hash = "sha256-Xu2lsqcGdKdRTEcWwIX6EFuEd87ImnWGI4Vp10aO37Y=";
    };
    vendorHash.__assign = "sha256-O18+Y7wlcSUFRo54jC4Ogb8AtnPuLG7rPhzIDCC6sjU=";
    # Patch the vendored library after buildGoModule has populated vendor/.
    postConfigure.__append = ''
      chmod -R u+w vendor/github.com/sagernet/sing-openvpn
      patch -d vendor/github.com/sagernet/sing-openvpn -p1 < ${
        final.fetchurl {
          # https://github.com/SagerNet/sing-openvpn/pull/6
          url = "https://github.com/SagerNet/sing-openvpn/commit/dcdfbabd94b96401d2ac0ed68b7450c363af3c09.patch";
          hash = "sha256-KU8OB2v7uyBp+3lnfrvo/bb5X4R1ufRpXznxvQaRGqY=";
        }
      }
    '';
  };

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
