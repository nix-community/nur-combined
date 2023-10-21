{ lib
, stdenv
, fetchurl
, mono
, pkg-config
, zstd
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "upkg";
  version = "1.4.0";

  src = fetchurl {
    url = "https://www.paldo.org/paldo/sources/upkg/upkg-${finalAttrs.version}.tar.zst";
    hash = "sha256-Xq/2EyKDzdvWTQsWpvmUBqfI/YBMWZwg2a7p7tDVTew=";
  };

  nativeBuildInputs = [
    mono
    pkg-config
    zstd # unpackPhase
  ];

  meta = {
    mainProgram = "upkg";
    description = "A complete automated source building system";
    homepage = "https://www.paldo.org/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
