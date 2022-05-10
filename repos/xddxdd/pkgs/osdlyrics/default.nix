{ stdenv
, lib
, sources
, writeText
, python3Packages
  # nativeBuildInputs
, autoreconfHook
, intltool
, pkg-config
  # buildInputs
, dbus-glib
, gtk2
, libnotify
, python3
, ...
} @ args:

let
  osdlyricsPython = python3Packages.buildPythonPackage rec {
    inherit (sources.osdlyrics) pname version src;

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

  python = python3.withPackages (p: with p; [
    chardet
    dbus-python
    future
    mpd2
    osdlyricsPython
    pycurl
    pygobject3
  ]);
in
stdenv.mkDerivation rec {
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
  postPatch = ''
    sed -i 's/-Werror//g' configure.ac
  '';
  preAutoreconf = ''
    export AUTOPOINT=intltoolize
  '';
  makeFlags = [ "PYTHON=${python}/bin/python" ];
  postInstall = ''
    rm -rf $out/lib/python*
  '';

  meta = with lib; {
    description = "Standalone lyrics fetcher/displayer (windowed and OSD mode).";
    homepage = "https://github.com/osdlyrics/osdlyrics";
    license = licenses.gpl3;
  };
}
