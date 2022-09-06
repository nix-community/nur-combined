{ lib, stdenv, mkDerivation, fetchFromGitHub, cmake, boost165, eigen, opencv2 }:

mkDerivation rec {
  pname = "polyvectorization";
  version = "2019-08-23";

  src = fetchFromGitHub {
    owner = "bmpix";
    repo = "PolyVectorization";
    rev = "bceb8e2a08cca29cef1df074eb1a1f6450cc163f";
    hash = "sha256-WI6EXoflj3vrxTPN+RyiTgst8JR9JV9yz7+3PHBAAjU=";
  };

  patches = [ ./with-gui.patch ];

  postPatch = ''
    substituteInPlace src/main.cpp \
      --replace "#define WITH_GUI 1" "//#define WITH_GUI 1"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [ boost165 eigen opencv2 ];

  NIX_CFLAGS_COMPILE = "-fpermissive";

  installPhase = "install -Dm755 polyvector_thing -t $out/bin";

  meta = with lib; {
    description = "Reference implementation of Vectorization of Line Drawings via PolyVector Fields";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    mainProgram = "polyvector_thing";
    skip.ci = stdenv.isDarwin;
  };
}
