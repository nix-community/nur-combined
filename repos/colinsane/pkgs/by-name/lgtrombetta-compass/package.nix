{
  lib,
  desktop-file-utils,
  fetchFromGitLab,
  gettext,
  glib,
  gobject-introspection,
  gtk3,
  libhandy,
  meson,
  ninja,
  python3,
  stdenv,
  versionCheckHook,
  wrapGAppsHook3,
}: stdenv.mkDerivation (finalAttrs: {
  pname = "lgtrombetta-compass";
  version = "0.4.0";

  src = fetchFromGitLab {
    owner = "lgtrombetta";
    repo = "compass";
    rev = "v${finalAttrs.version}";
    hash = "sha256-NXy9JihGwpDaZmNUNUAOYfqQTWQM4dXtTQ/4Ukgi11U=";
  };

  nativeBuildInputs = [
    desktop-file-utils # for update-desktop-database
    gettext  # for msgfmt
    glib  # for glib-compile-resources
    gobject-introspection  # for setup-hook that populates GI_TYPELIB_PATH
    gtk3  # for gtk-update-icon-cache
    meson
    ninja
    python3
    python3.pkgs.wrapPython
    wrapGAppsHook3
  ];

  buildInputs = [
    glib  # for gio
    gtk3
    libhandy
    python3
  ];

  propagatedBuildInputs = [
    python3.pkgs.matplotlib
    python3.pkgs.numpy
    python3.pkgs.pandas
    python3.pkgs.pygobject3
    python3.pkgs.pyxdg
  ];

  nativeCheckInputs = [
    # python3.pkgs.pythonImportsCheckHook
    versionCheckHook
  ];

  pythonImportsCheck = [
    "compass"
  ];

  postPatch = ''
    substituteInPlace data/meson.build \
      --replace-fail "install_dir: '/lib/udev/rules.d'" "install_dir: join_paths(get_option('datadir'), 'lib/udev/rules.d')"
  '';

  preConfigure = ''
    patchShebangs --build build-aux/meson/postinstall.py
  '';

  postFixup = ''
    wrapPythonPrograms
  '';

  preInstallCheck = ''
    version=v$version
  '';

  versionCheckProgram = "${placeholder "out"}/bin/compass";

  doCheck = true;
  doInstallCheck = true;
  strictDeps = true;

  meta = with lib; {
    homepage = "https://gitlab.com/lgtrombetta/compass";
    description = "a simple GTK3 compass app for Mobile Linux";
    maintainers = with maintainers; [ colinsane ];
  };
})
