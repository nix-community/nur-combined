{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  libjpeg,
  libpng,
  libtiff,
  libgeotiff,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tile-stitch";
  version = "0-unstable-2019-07-11";

  src = fetchFromGitHub {
    owner = "e-n-f";
    repo = "tile-stitch";
    rev = "f14d113c54bb7dcffee05a7608a806b8557139e5";
    hash = "sha256-EEQ/8NbcB1O1rqlDWyYw7ERDQCm4j8YGv7z8WTVVCfc=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    curl
    libjpeg
    libpng
    libtiff
    libgeotiff
  ];

  installPhase = "install -Dm755 stitch -t $out/bin";

  meta = {
    description = "Stitch together and crop map tiles for a specified bounding box";
    homepage = "https://github.com/e-n-f/tile-stitch";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
