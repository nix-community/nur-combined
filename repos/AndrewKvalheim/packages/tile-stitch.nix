{ fetchFromGitHub
, lib
, stdenv
, unstableGitUpdater

  # Dependencies
, curl
, libgeotiff
, libjpeg
, libpng
, libtiff
, pkg-config
}:

stdenv.mkDerivation {
  pname = "tile-stitch";
  version = "0-unstable-2019-07-10";

  src = fetchFromGitHub {
    owner = "e-n-f";
    repo = "tile-stitch";
    rev = "f14d113c54bb7dcffee05a7608a806b8557139e5";
    hash = "sha256-EEQ/8NbcB1O1rqlDWyYw7ERDQCm4j8YGv7z8WTVVCfc=";
  };

  buildInputs = [ curl libgeotiff libjpeg libpng libtiff pkg-config ];

  installPhase = ''
    install -D stitch $out/bin/tile-stitch
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Stitch together and crop map tiles for a specified bounding box";
    homepage = "https://github.com/e-n-f/tile-stitch";
    license = lib.licenses.bsd2;
  };
}
