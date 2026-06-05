{
  desktop-file-utils,
  fetchFromGitLab,
  gettext,
  glib,
  gobject-introspection,
  gtk3,
  lib,
  meson,
  ninja,
  python3,
  stdenv,
  wrapGAppsHook3,
}:
let
  # optional deps: avahi, python-keyring
  pythonEnv = python3.withPackages (ps: with ps; [ python-dateutil pygobject3 ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "mcg";
  version = "3.2.1";
  src = fetchFromGitLab {
    owner = "coderkun";
    repo = "mcg";
    rev = "v${finalAttrs.version}";
    hash = "sha256-awPMXGruCB/2nwfDqYlc0Uu9E6VV1AleEZAw9Xdsbt8=";
  };

  postPatch = ''
    substituteInPlace src/meson.build \
      --replace-fail "python.find_installation('python3').full_path()" "'${lib.getExe pythonEnv}'"
  '';

  nativeBuildInputs = [
    gtk3  # for gtk-update-icon-cache
    desktop-file-utils  # for update-desktop-database
    gettext  # for msgfmt
    glib  # for glib-compile-resources
    gobject-introspection  # needed so wrapGAppsHook3 includes GI_TYPEPATHS for gtk3
    meson
    ninja
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
  ];

  meta = {
    description = "CoverGrid (mcg) is a client for the Music Player Daemon (MPD), focusing on albums instead of single tracks.";
    homepage = "https://www.suruatoel.xyz/codes/mcg";
    platforms = lib.platforms.linux;
    # license = TODO
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
