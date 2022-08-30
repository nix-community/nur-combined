{ lib
, stdenv
, fetchFromGitHub
, meson
, sassc
, pkg-config
, glib
, ninja
, python3
, gtk3
, gnome
, gtk-engine-murrine
, humanity-icon-theme
, hicolor-icon-theme
}:

stdenv.mkDerivation rec {
  pname = "yaru-classic";
  version = "22.10.1.1";

  src = fetchFromGitHub {
    owner = "lourkeur";
    repo = "yaru-classic";
    rev = version;
    sha256 = "sha256-TU6NhqVVKGnbEJrK2Maf4eMSICeBahT83FAkYhzQTco=";
  };

  nativeBuildInputs = [ meson sassc pkg-config glib ninja python3 ];

  buildInputs = [ gtk3 gnome.gnome-themes-extra ];

  propagatedBuildInputs = [ humanity-icon-theme hicolor-icon-theme ];

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  dontDropIconThemeCache = true;

  postPatch = "patchShebangs .";

  meta = with lib; {
    description = "Ubuntu community theme 'yaru' - default Ubuntu theme since 18.10";
    homepage = "https://github.com/lourkeur/yaru-classic";
    license = with licenses; [ cc-by-sa-40 gpl3Plus lgpl21Only lgpl3Only ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ lourkeur ];
  };
}
