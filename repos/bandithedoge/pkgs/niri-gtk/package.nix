{
  sources,

  lib,
  stdenv,

  astal,
  glib,
  gobject-introspection,
  json-glib,
  meson,
  ninja,
  pkg-config,
  vala,
}:
stdenv.mkDerivation {
  inherit (sources.niri-gtk) pname src;
  sourceRoot = "${sources.niri-gtk.src.name}/src";
  version = sources.niri-gtk.date;

  nativeBuildInputs = [
    gobject-introspection
    meson
    ninja
    pkg-config
    vala
  ];

  propagatedBuildInputs = [
    glib
    json-glib
  ];

  postUnpack = ''
    cp --remove-destination ${astal.source}/lib/gir.py gir.py
  '';

  meta = {
    description = "GTK Library and CLI tool for monitoring the Niri socket";
    homepage = "https://github.com/sameoldlab/niri-gtk";
    license = lib.licenses.lgpl21;
    platforms = lib.platforms.linux;
    mainProgram = "astal-niri";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
