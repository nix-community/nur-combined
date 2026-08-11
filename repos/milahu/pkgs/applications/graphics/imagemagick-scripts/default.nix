{ lib
, stdenvNoCC
, fetchFromGitHub
, bc
, coreutils-full
, gawk
, gnugrep
, gnused
, imagemagick
}:

stdenvNoCC.mkDerivation rec {
  pname = "imagemagick-scripts";
  version = "unstable-2024-07-16";

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "imagemagick-scripts";
    rev = "7af65e4d08b3d2f4c74df456c486aa2d65d33006";
    hash = "sha256-pOW14F+bVDjNLkkm3sFlR5Eep6nxFVw+/ikxDuFPOSg=";
  };

  propagatedBuildInputs = [
    bc
    coreutils-full
    gawk
    gnugrep
    gnused
    imagemagick
  ];

  buildPhase = ''
    sed -i '1 a\export PATH="${lib.makeBinPath propagatedBuildInputs}:$PATH"' bin/*
  '';

  installPhase = ''
    mkdir $out
    cp -r bin $out
  '';

  meta = with lib; {
    description = "Fred's ImageMagick Scripts";
    homepage = "https://github.com/milahu/imagemagick-scripts";
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
