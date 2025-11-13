{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
}:

stdenv.mkDerivation {
  pname = "vectiler";
  version = "0.1.0-unstable-2024-05-20";

  src = fetchFromGitHub {
    owner = "karimnaaji";
    repo = "vectiler";
    rev = "f9bd89e9446a91c26aa26d135646327d9b715e13";
    hash = "sha256-lKP9Dc9T1pa+A/PM9KeT2aKGR0mkjR7oMQ0T/2jDOAY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ curl ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.10")
  ];

  installPhase = ''
    install -Dm755 vectiler.out $out/bin/vectiler
  '';

  meta = {
    description = "A vector tile, terrain and city 3d model builder and exporter";
    homepage = "http://karim.naaji.fr/vectiler.html";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "vectiler";
  };
}
