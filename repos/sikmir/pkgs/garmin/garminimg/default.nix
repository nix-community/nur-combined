{ lib, mkDerivation, fetchFromGitHub, cmake, gdal, proj }:

mkDerivation rec {
  pname = "garminimg";
  version = "2021-01-07";

  src = fetchFromGitHub {
    owner = "kiozen";
    repo = "GarminImg";
    rev = "6bfd029e9712b47eeab144bfe150baccd8c879bd";
    hash = "sha256-6vNN80NJSo2GdGruUKTupMcWOR7E3vo2SD1fAkMCodE=";
  };

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
    description = "Encode/decode a Garmin IMG file";
    inherit (src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
