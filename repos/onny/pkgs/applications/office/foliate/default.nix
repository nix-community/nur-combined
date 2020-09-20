{ stdenv
, fetchFromGitHub
, meson
, ninja
, gettext
, pkgconfig
, python3
, wrapGAppsHook
, gobject-introspection
, gjs
, gtk3
, gsettings-desktop-schemas
, webkitgtk
, glib
, desktop-file-utils
, hicolor-icon-theme /* setup hook */
, libarchive
/*, hyphen */
, dict
}:

stdenv.mkDerivation rec {
  pname = "foliate";
  version = "2.4.2";

  src = fetchFromGitHub {
    owner = "johnfactotum";
    repo = pname;
    rev = version;
    sha256 = "0yryzal65pyv6p8yfmnjbx1m284vw4dv4qh56galm1s3lc3ssm5h";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkgconfig
    gettext
    python3
    desktop-file-utils
    wrapGAppsHook
    hicolor-icon-theme
  ];

  buildInputs = [
    glib
    gtk3
    gjs
    webkitgtk
    gsettings-desktop-schemas
    gobject-introspection
    libarchive
    # TODO: Add once packaged, unclear how language packages best handled
    # hyphen
    dict # dictd for offline dictionary support
  ];

  doCheck = true;

  postPatch = ''
    chmod +x build-aux/meson/postinstall.py
    patchShebangs build-aux/meson/postinstall.py
  '';

  dontWrapGApps = true;

  # Fixes https://github.com/NixOS/nixpkgs/issues/31168
  # postInstall = ''
  postFixup = ''
    sed -e $'2iimports.package._findEffectiveEntryPointName = () => \'com.github.johnfactotum.Foliate\' ' \
      -i $out/bin/com.github.johnfactotum.Foliate
    wrapGApp $out/bin/com.github.johnfactotum.Foliate
  '';

  meta = with stdenv.lib; {
    description = "Simple and modern GTK eBook reader";
    homepage = "https://johnfactotum.github.io/foliate/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ dtzWill ];
  };
}

