{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
  writeText,
  python3Packages,
  # nativeBuildInputs
  autoreconfHook,
  intltool,
  pkg-config,
  # buildInputs
  dbus-glib,
  gtk2,
  libnotify,
  python3,
}:
let
  version = "0.5.16";

  osdlyricsPython = python3Packages.buildPythonPackage (finalAttrs: {
    pname = "osdlyrics";
    inherit version;
    pyproject = true;

    src = fetchFromGitHub {
      owner = "osdlyrics";
      repo = "osdlyrics";
      tag = finalAttrs.version;
      hash = "sha256-GvvFtpiuWuHh1dxd7Hd9F9M0WyVOtN0LxZJzGGB0mVA=";
    };
    build-system = [ python3Packages.setuptools ];

    configurePhase =
      let
        setupPy = writeText "setup.py" ''
          from setuptools import setup, find_packages
          setup(
            name='${finalAttrs.pname}',
            version='${finalAttrs.version}',
            packages=['osdlyrics', 'osdlyrics/dbusext'],
          )
        '';
        initPy = writeText "__init__.py" ''
          PROGRAM_NAME = 'OSD Lyrics'
          PACKAGE_NAME = '${finalAttrs.pname}'
          PACKAGE_VERSION = '${finalAttrs.version}'
        '';
      in
      ''
        ln -s ${setupPy} setup.py
        mv python osdlyrics
        ln -s ${initPy} osdlyrics/__init__.py
      '';

    doCheck = false;
  });

  python = python3.withPackages (
    p: with p; [
      chardet
      dbus-python
      mpd2
      osdlyricsPython
      pycurl
      pygobject3
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "osdlyrics";
  inherit version;
  src = fetchFromGitHub {
    owner = "osdlyrics";
    repo = "osdlyrics";
    tag = finalAttrs.version;
    hash = "sha256-GvvFtpiuWuHh1dxd7Hd9F9M0WyVOtN0LxZJzGGB0mVA=";
  };
  nativeBuildInputs = [
    autoreconfHook
    intltool
    pkg-config
  ];
  buildInputs = [
    dbus-glib
    gtk2
    libnotify
    python
  ];

  patches = [ ./fix-build.patch ];

  preAutoreconf = ''
    export AUTOPOINT=intltoolize
  '';
  makeFlags = [ "PYTHON=${python}/bin/python" ];
  postInstall = ''
    rm -rf $out/lib/python*
  '';

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/osdlyrics/osdlyrics/releases/tag/${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Standalone lyrics fetcher/displayer (windowed and OSD mode)";
    homepage = "https://github.com/osdlyrics/osdlyrics";
    license = lib.licenses.gpl3Only;
    mainProgram = "osdlyrics";
  };
})
