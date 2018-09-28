{ stdenv, fetchFromGitHub
, cmake
, qtbase, qtquickcontrols2, SDL
, python3 }:

stdenv.mkDerivation rec {
  name = "sfxr-qt-${version}";
  version = "unstable-2018-09-02";
  src = fetchFromGitHub {
    owner = "agateau";
    repo = "sfxr-qt";
    rev = "b1da2f0a7dbcefa3b52310b1a4b4cb2b638d841b";
    sha256 = "1bcz63qaklysijls3lq9xqv6887x3d06bqclnpqdbjyl729pwvgg";
    fetchSubmodules = true;
  };
  nativeBuildInputs = [ cmake ];
  buildInputs = [
    qtbase qtquickcontrols2 SDL
    (python3.withPackages (pp: with pp; [ pyyaml jinja2 ]))
  ];
  configurePhase = "cmake . -DCMAKE_INSTALL_PREFIX=$out";
  meta.broken = true;
}

