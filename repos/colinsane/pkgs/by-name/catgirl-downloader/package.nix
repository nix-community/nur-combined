{
  appstream-glib,
  desktop-file-utils,
  fetchFromGitHub,
  gitUpdater,
  gobject-introspection,
  gtk4,
  lib,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python3,
  stdenv,
  testers,
  wrapGAppsHook4,
}:
let
  pythonEnv = python3.withPackages (ps: with ps; [
    pygobject3
    requests
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "catgirl-downloader";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "NyarchLinux";
    repo = "CatgirlDownloader";
    rev = finalAttrs.version;
    hash = "sha256-+RyQOgqPZN3AnVdd5mtgppQ/z51VIEeEsiW2RFTnVbk=";
  };

  # fix meson to use the host python when cross compiling.
  # this is a "known issue": <https://github.com/mesonbuild/meson/issues/12540>.
  # somehow `buildPythonApplication` gets around this, if one were to use that for the packaging.
  postPatch = ''
    substituteInPlace src/meson.build --replace-fail \
      "python.find_installation('python3').path()" \
      "'${pythonEnv.interpreter}'"
  '';

  nativeBuildInputs = [
    appstream-glib # for appstream-util
    desktop-file-utils # for update-desktop-database
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
    # pythonEnv  #< not needed as we patch it in directly
  ];

  strictDeps = true;

  passthru = {
    inherit pythonEnv;
    updateScript = gitUpdater { };
    # TODO: `catgirldownloader` doesn't implement `--version` flag (only `--help`, which doesn't show version)
    # tests.version = testers.testVersion {
    #   package = finalAttrs.finalPackage;
    # };
  };

  meta = {
    homepage = "https://github.com/NyarchLinux/CatgirlDownloader";
    description = "GTK4 application that downloads images of catgirl based on https://nekos.moe";
    maintainers = with lib.maintainers; [ colinsane ];
    mainProgram = "catgirldownloader";
  };
})
