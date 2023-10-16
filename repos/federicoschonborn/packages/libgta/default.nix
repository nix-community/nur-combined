{ lib
, stdenv
, fetchzip
, cmake
, doxygen
, ninja
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libgta";
  version = "1.2.1";

  src = fetchzip {
    url = "https://marlam.de/gta/releases/libgta-${finalAttrs.version}.tar.xz";
    hash = "sha256-Agf2KU4MqmbLwJiP9W+8pFGM3xgnn8p/b1vT1Ua9LXw=";
  };

  nativeBuildInputs = [
    cmake
    doxygen
    ninja
  ];

  meta = {
    description = "A library that reads and writes GTA files, with interfaces in C and C++";
    homepage = "https://marlam.de/gta/";
    downloadPage = "https://marlam.de/gta/download/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
