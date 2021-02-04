{ lib, stdenv, curl, libjpeg, libpng, libtiff, libgeotiff, pkg-config, sources }:

stdenv.mkDerivation {
  pname = "tile-stitch";
  version = lib.substring 0 10 sources.tile-stitch.date;

  src = sources.tile-stitch;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ curl libjpeg libpng libtiff libgeotiff ];

  installPhase = "install -Dm755 stitch -t $out/bin";

  meta = with lib; {
    inherit (sources.tile-stitch) description homepage;
    license = licenses.bsd2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
