{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  qt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gps-whatsnew";
  version = "2017-01-23";

  src = fetchFromGitHub {
    owner = "centurn";
    repo = "gps-whatsnew";
    rev = "b856f0b7472ed6287920a41568d951e0a0330387";
    hash = "sha256-lZSjFdaQizXYi0OTChOKrSwllgzOCy6gTbBohcegJxk=";
  };

  postPatch = ''
    sed -i '1 i #include <iostream>' gps_analyze.cpp
  '';

  nativeBuildInputs = [ qt5.qmake ];
  buildInputs = [ boost ];

  dontWrapQtApps = true;

  installPhase = ''
    install -Dm755 gps-whatsnew -t $out/bin
  '';

  meta = {
    description = "Compare gpx tracks to find new segments (places never traveled before)";
    homepage = "https://github.com/centurn/gps-whatsnew";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
