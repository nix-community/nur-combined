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

let
  inherit (lib) licenses;
in
stdenv.mkDerivation {
  pname = "tile-stitch";
  version = "0-unstable-2019-07-10";
  meta = {
    description = "Stitch together and crop map tiles for a specified bounding box";
    homepage = "https://github.com/e-n-f/tile-stitch";
    license = licenses.bsd2;
  };

  passthru.updateScript = unstableGitUpdater { };

  src = fetchFromGitHub {
    owner = "e-n-f";
    repo = "tile-stitch";
    rev = "f14d113c54bb7dcffee05a7608a806b8557139e5";
    hash = "sha256-EEQ/8NbcB1O1rqlDWyYw7ERDQCm4j8YGv7z8WTVVCfc=";
  };

  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    curl
    libgeotiff
    libjpeg
    libpng
    libtiff
  ];

  installPhase = ''
    install -D 'stitch' "$out/bin/tile-stitch"
  '';
}
