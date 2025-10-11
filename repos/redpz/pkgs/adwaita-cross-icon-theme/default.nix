{
  lib,
  stdenv,
  fetchurl,
  meson,
  ninja,
  pkg-config,
  gnome,
  gtk3,
  gdk-pixbuf,
  librsvg,
  hicolor-icon-theme,
  tree,
}:

stdenv.mkDerivation rec {
  pname = "adwaita-icon-theme";
  version = "48.0";

  src = fetchurl {
    url = "mirror://gnome/sources/adwaita-icon-theme/${lib.versions.major version}/adwaita-icon-theme-${version}.tar.xz";
    hash = "sha256-hHBoiIZQ2WcxFb5tvyv9wxpGrrxSimqdtEIOYOZWuNQ=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gtk3
    tree
  ];

  buildInputs = [
    gdk-pixbuf
    librsvg
  ];

  propagatedBuildInputs = [
    # For convenience, we can specify adwaita-icon-theme only in packages
    hicolor-icon-theme
  ];

  postPatch = ''
    # Postpone these changes for now, please discuss in https://github.com/NixOS/nixpkgs/pull/316416
    substituteInPlace index.theme \
      --replace-fail "Hidden=true" "" \
      --replace-fail "Inherits=AdwaitaLegacy,hicolor" "Inherits=hicolor"

  '';

  postInstall = ''
    mv $out/share/icons/Adwaita $out/share/icons/Adwaita-cross
    rm $out/share/icons/Adwaita-cross/cursors/arrow
    ln -s $out/share/icons/Adwaita-cross/cursors/crosshair $out/share/icons/Adwaita-cross/cursors/arrow
    sed -i '0,/Adwaita/{s/Adwaita/Adwaita-cross/}' $out/share/icons/Adwaita-cross/index.theme
  '';

  dontDropIconThemeCache = true;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "adwaita-icon-theme";
    };
  };

  meta = with lib; {
    homepage = "https://gitlab.gnome.org/GNOME/adwaita-icon-theme";
    changelog = "https://gitlab.gnome.org/GNOME/adwaita-icon-theme/-/blob/${version}/NEWS?ref_type=tags";
    platforms = with platforms; linux ++ darwin;
    teams = [ teams.gnome ];
    license = licenses.cc-by-sa-30;
  };
}
