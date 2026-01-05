{
  stdenv,
  lib,
  sources,
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
  osdlyricsPython = python3Packages.buildPythonPackage rec {
    inherit (sources.osdlyrics) pname version src;
    pyproject = true;
    build-system = [ python3Packages.setuptools ];

    configurePhase =
      let
        setupPy = writeText "setup.py" ''
          from setuptools import setup, find_packages
          setup(
            name='${pname}',
            version='${version}',
            packages=['osdlyrics', 'osdlyrics/dbusext'],
          )
        '';
        initPy = writeText "__init__.py" ''
          PROGRAM_NAME = 'OSD Lyrics'
          PACKAGE_NAME = '${pname}'
          PACKAGE_VERSION = '${version}'
        '';
      in
      ''
        ln -s ${setupPy} setup.py
        mv python osdlyrics
        ln -s ${initPy} osdlyrics/__init__.py
      '';

    doCheck = false;
  };

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
  inherit (sources.osdlyrics) pname version src;
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

  meta = {
    changelog = "https://github.com/osdlyrics/osdlyrics/releases/tag/${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Standalone lyrics fetcher/displayer (windowed and OSD mode)";
    homepage = "https://github.com/osdlyrics/osdlyrics";
    license = lib.licenses.gpl3Only;
    mainProgram = "osdlyrics";
  };
})
