{ lib
, stdenv
, fetchzip
, cmake
, ninja
, muparser
, readline
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mucalc";
  version = "2.1";

  src = fetchzip {
    url = "https://marlam.de/mucalc/releases/mucalc-${finalAttrs.version}.tar.gz";
    hash = "sha256-qXqe9U7y3YrzSeJKgW53vkdNpPcAmxysxzT7SIlSzMo=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    muparser
    readline
  ];

  meta = {
    mainProgram = "mucalc";
    description = "A convenient calculator for the command line";
    homepage = "https://marlam.de/mucalc/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    broken = stdenv.isDarwin;
  };
})
