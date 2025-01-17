# out for review: <https://github.com/NixOS/nixpkgs/pull/363748>
{
  appstream,
  desktop-file-utils,
  fetchFromGitHub,
  glib,
  gobject-introspection,
  gsound,
  gtk4,
  libadwaita,
  lib,
  libsecret,
  meson,
  ninja,
  pkg-config,
  python3,
  stdenv,
  unstableGitUpdater,
  webkitgtk_6_0,
  wrapGAppsHook4,
}: stdenv.mkDerivation (finalAttrs: {
  pname = "reminders";
  version = "5.0.rc-unstable-2023-05-03";

  src = fetchFromGitHub {
    owner = "remindersdevs";
    repo = "Reminders";
    rev = "f649ea653b43d3ff0ef331729eb043fbb912f6f7";
    hash = "sha256-dhtspgHM+HWqDSNdF4O/NOyDGcL7aADsm0yT5MKjw3k=";
  };

  nativeBuildInputs = [
    appstream  # for appstreamcli
    desktop-file-utils  # for desktop-file-validate
    glib  # for glib-compile-schemas
    gtk4  # for gtk-update-icon-cache
    meson
    ninja
    pkg-config
    python3.pkgs.wrapPython
    wrapGAppsHook4
  ];

  buildInputs = [
    gobject-introspection
    gsound
    libadwaita
    libsecret
    webkitgtk_6_0
  ];

  propagatedBuildInputs = [
    python3.pkgs.caldav
    python3.pkgs.icalendar
    python3.pkgs.msal
    python3.pkgs.pygobject3
    python3.pkgs.requests
    python3.pkgs.setuptools
  ];

  nativeCheckInputs = [
    # python3.pkgs.pytestCheckHook
    python3.pkgs.pythonImportsCheckHook
  ];

  pythonImportsCheck = [
    "reminders"
  ];

  doCheck = true;
  #vvv optional: avoid double-wrapping
  # dontWrapGApps = true;
  # makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];

  postFixup = ''
    wrapPythonPrograms
    wrapPythonProgramsIn $out/libexec $out $pythonPath
  '';

  passthru.updateScript = unstableGitUpdater {
    tagPrefix = "v";
  };

  meta = with lib; {
    description = "Open source reminder app";
    homepage = "https://github.com/remindersdevs/Reminders";
    license = with lib.licenses; [ gpl3Plus ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ colinsane pluiedev ];
    mainProgram = "reminders";

  };
})
