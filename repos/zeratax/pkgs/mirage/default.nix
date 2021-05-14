{ lib, stdenv, mkDerivation, fetchFromGitHub
, qmake, pkg-config, olm, wrapQtAppsHook
, qtbase, qtquickcontrols2, qtkeychain, qtmultimedia, qtgraphicaleffects
, python3Packages, pyotherside, libXScrnSaver
}:

let
  pypkgs = with python3Packages; [
    aiofiles filetype matrix-nio appdirs cairosvg
    pymediainfo setuptools html-sanitizer mistune
    pyotherside plyer sortedcontainers watchgod
    redbaron hsluv simpleaudio dbus-python
  ];
in
mkDerivation rec {
  version = "0.7.1";
  pname = "mirage";

  src = fetchFromGitHub {
    owner = "mirukana";
    repo = pname;
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "0j7gdg2z8yg3qvwg9d9fa3i4ig231qda48p00s5gk8bc3c65vsll";
  };

  nativeBuildInputs = [ pkg-config qmake wrapQtAppsHook python3Packages.wrapPython ];

  buildInputs = [
    qtbase qtmultimedia
    qtquickcontrols2
    qtkeychain qtgraphicaleffects
    olm pyotherside
    libXScrnSaver
  ];

  propagatedBuildInputs = pypkgs;

  pythonPath = pypkgs;

  qmakeFlags = [ "PREFIX=${placeholder "out"}" "CONFIG+=qtquickcompiler" ];

  dontWrapQtApps = true;
  postInstall = ''
    buildPythonPath "$out $pythonPath"
    wrapProgram $out/bin/mirage \
      --prefix PYTHONPATH : "$PYTHONPATH" \
      "''${qtWrapperArgs[@]}"
    '';


  meta = with lib; {
    homepage = "https://github.com/mirukana/mirage/";
    description =
      "A fancy, customizable, keyboard-operable Qt/QML+Python Matrix chat client for encrypted and decentralized communication.";
    license = licenses.lgpl3;
    # maintainers = with maintainers; [ zeratax ];
  };
}

