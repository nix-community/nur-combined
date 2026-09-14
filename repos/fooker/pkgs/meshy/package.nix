{
  lib,
  stdenv,
  fetchFromCodeberg,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook4,
  desktop-file-utils,
  gobject-introspection,
  appstream,
  gettext,
  glib,
  gtk4,
  libadwaita,
  gst_all_1,
  libshumate,
  geoclue2,
  zbar,
  python3,
  enableQrScanner ? true,
  enableShortcutsDialog ? true,
}:

let
  pythonDeps = with python3.pkgs; [
    pygobject3
    pycryptodome
    pyserial
    segno
  ] ++ lib.optionals enableQrScanner [ pyzbar ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "meshy";
  version = "26.09";

  src = fetchFromCodeberg {
    owner = "sesivany";
    repo = "meshy";
    rev = finalAttrs.version;
    hash = "sha256-U23MuusLKePra/qe+J1Co7aeIwmVmKTegE8BM8j4md4=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    desktop-file-utils
    appstream
    gettext
    glib
    python3
    gobject-introspection
  ];

  buildInputs = [
    gtk4
    libadwaita
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    libshumate
    geoclue2
  ] ++ lib.optionals enableQrScanner [ zbar ];

  mesonFlags = [
    "-Dqr_scanner=${lib.boolToString enableQrScanner}"
    "-Dshortcuts_dialog=${lib.boolToString enableShortcutsDialog}"
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PYTHONPATH : "$out/${python3.sitePackages}:${python3.pkgs.makePythonPath pythonDeps}"
    )
  '';

  meta = with lib; {
    description = "GTK4/libadwaita client for MeshCore";
    homepage = "https://codeberg.org/sesivany/meshy";
    license = licenses.gpl3Plus;
    mainProgram = "meshy";
    platforms = platforms.linux;
  };
})
