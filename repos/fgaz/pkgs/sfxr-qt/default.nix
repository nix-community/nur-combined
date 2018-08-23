{ stdenv, fetchFromGitHub
, cmake
, qtbase, qtquickcontrols2, SDL
, python3 }:

stdenv.mkDerivation rec {
  name = "sfxr-qt-${version}";
  version = "1.1.0";
  src = fetchFromGitHub {
    owner = "agateau";
    repo = "sfxr-qt";
    rev = "${version}";
    sha256 = null;
    fetchSubmodules = true;
  };
  nativeBuildInputs = [ cmake ];
  buildInputs = [
    qtbase qtquickcontrols2 SDL
    (python3.withPackages (pp: with pp; [ pyyaml jinja2 ]))
  ];
  configurePhase = "cmake . -DCMAKE_INSTALL_PREFIX=$out";
  meta.broken = true; # works on my machine but not on travis... TODO investigate
}

