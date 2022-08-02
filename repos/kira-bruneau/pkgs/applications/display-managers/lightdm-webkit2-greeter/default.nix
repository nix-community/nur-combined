{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, wrapGAppsHook
, dbus-glib
, gtk3
, lightdm
, webkitgtk
, linkFarm
, lightdm-webkit2-greeter
}:

stdenv.mkDerivation rec {
  pname = "lightdm-webkit2-greeter";
  version = "2.2.5";

  src = fetchFromGitHub {
    owner = "Antergos";
    repo = "web-greeter";
    rev = "refs/tags/${version}";
    sha256 = "sha256-LY7sVaxBwjojzFa00OkvgR9+TIZuH/WW12UsfpffOIE=";
  };

  outputs = [ "out" "man" ];

  patches = [
    # Support absolute paths in webkit_theme, so custom themes can be selected by a Nix store path
    ./absolute-theme-paths.patch

    # Install default config relative to install prefix
    ./relative-config-install.patch

    # Fixes some of the deprecated functions
    ./fix-deprecated.patch

    # Fix SEGFAULT on startup
    ./fix-double-free.patch

    # Fix loading branding from config into greeter_config.branding JS variable
    ./fix-greeter-config-branding.patch

    # Fix antegros theme crash when hitting escape at password entry
    ./fix-non-click-cancel.patch

    # Fix file requests to symlinks in allowed paths
    ./fix-requesting-symlinks.patch
  ];

  postPatch = "patchShebangs build/utils.sh";

  nativeBuildInputs = [ meson ninja pkg-config wrapGAppsHook ];
  buildInputs = [ dbus-glib gtk3 lightdm webkitgtk ];

  mesonFlags = [
    "-Dwith-theme-dir=${placeholder "out"}/share/lightdm-webkit/themes"
    "-Dwith-desktop-dir=${placeholder "out"}/share/xgreeters"
    "-Dwith-webext-dir=${placeholder "out"}/lib/lightdm-webkit2-greeter"
    "-Dwith-locale-dir=${placeholder "out"}/share/locale"
  ];

  postFixup = ''
    substituteInPlace $out/share/xgreeters/lightdm-webkit2-greeter.desktop \
      --replace "Exec=lightdm-webkit2-greeter" "Exec=$out/bin/lightdm-webkit2-greeter"
  '';

  passthru.xgreeters = linkFarm "lightdm-webkit2-greeter-xgreeters" [{
    path = "${lightdm-webkit2-greeter}/share/xgreeters/lightdm-webkit2-greeter.desktop";
    name = "lightdm-webkit2-greeter.desktop";
  }];

  meta = with lib; {
    description = "A modern, visually appealing greeter for LightDM";
    homepage = "https://github.com/Antergos/web-greeter";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = platforms.linux;
  };
}
