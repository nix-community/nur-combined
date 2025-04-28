{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gdal,
  proj,
  wrapQtAppsHook,
}:

stdenv.mkDerivation {
  pname = "garminimg";
  version = "0-unstable-2021-01-07";

  src = fetchFromGitHub {
    owner = "kiozen";
    repo = "GarminImg";
    rev = "6bfd029e9712b47eeab144bfe150baccd8c879bd";
    hash = "sha256-6vNN80NJSo2GdGruUKTupMcWOR7E3vo2SD1fAkMCodE=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "PROJ4" "PROJ"
    substituteInPlace srcEncodeImg/CMakeLists.txt \
      --replace-fail "PROJ4_" "PROJ_"
    substituteInPlace srcDecodeImg/CMakeLists.txt \
      --replace-fail "PROJ4_" "PROJ_"
  '';

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
  ];

  buildInputs = [
    gdal
    proj
  ];

  hardeningDisable = [ "format" ];

  installPhase = ''
    install -Dm755 bin/* -t $out/bin
  '';

  meta = {
    description = "Encode/decode a Garmin IMG file";
    homepage = "https://github.com/kiozen/GarminImg";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    broken = true; # proj_7 is broken
  };
}
