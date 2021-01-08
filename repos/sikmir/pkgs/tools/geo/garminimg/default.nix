{ lib, mkDerivation, cmake, gdal, proj, sources }:

mkDerivation {
  pname = "garminimg";
  version = lib.substring 0 10 sources.garminimg.date;

  src = sources.garminimg;

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "PROJ4" "PROJ"
    substituteInPlace srcEncodeImg/CMakeLists.txt \
      --replace "PROJ4_" "PROJ_"
    substituteInPlace srcDecodeImg/CMakeLists.txt \
      --replace "PROJ4_" "PROJ_"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [ gdal proj ];

  hardeningDisable = [ "format" ];

  installPhase = "install -Dm755 bin/* -t $out/bin";

  meta = with lib; {
    inherit (sources.garminimg) description homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
