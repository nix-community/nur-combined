{
  lib,
  stdenv,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  vala,
  glib,
  gobject-introspection,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "libhighscore";
  version = "0-unstable-2025-06-25";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "alicem";
    repo = "libhighscore";
    rev = "8e3426ef842f29178c016da037354251716a6a72";
    hash = "sha256-yCnsyYWWBFewKYGGcALIFjjiUn8vdqH/4+qRV0X4ta0=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
  ];

  buildInputs = [
    glib
    gobject-introspection
  ];

  strictDeps = true;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Interface for porting emulators to
Highscore";
    homepage = "https://gitlab.gnome.org/alicem/libhighscore";
    license = lib.licenses.lgpl21Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
