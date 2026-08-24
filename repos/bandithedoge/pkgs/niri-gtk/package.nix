{
  fetchFromGitHub,
  lib,
  nix-update-script,
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
  pname = "niri-gtk";
  version = "0-unstable-2026-08-22";
  src = fetchFromGitHub {
    owner = "sameoldlab";
    repo = "niri-gtk";
    rev = "249eb454468bab9720a11208ac2caac4c4a0f6a1";
    hash = "sha256-/1Mz5Thei7MispevH8wz2+YFkG8FSK7Vu/pf8PlbfNo=";
  };
  sourceRoot = "source/src";

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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "GTK Library and CLI tool for monitoring the Niri socket";
    homepage = "https://github.com/sameoldlab/niri-gtk";
    license = lib.licenses.lgpl21;
    platforms = lib.platforms.linux;
    mainProgram = "astal-niri";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
