{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  boost,
  eigen,
  opencv,
  qt5,
}:

stdenv.mkDerivation {
  pname = "polyvectorization";
  version = "0-unstable-2019-08-23";

  src = fetchFromGitHub {
    owner = "bmpix";
    repo = "PolyVectorization";
    rev = "bceb8e2a08cca29cef1df074eb1a1f6450cc163f";
    hash = "sha256-WI6EXoflj3vrxTPN+RyiTgst8JR9JV9yz7+3PHBAAjU=";
  };

  patches = [ ./with-gui.patch ];

  postPatch = ''
    substituteInPlace src/main.cpp \
      --replace-fail "#define WITH_GUI 1" "//#define WITH_GUI 1"
  '';

  nativeBuildInputs = [
    cmake
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    boost
    eigen
    opencv
  ];

  env.NIX_CFLAGS_COMPILE = "-fpermissive";

  installPhase = ''
    install -Dm755 polyvector_thing -t $out/bin
  '';

  meta = {
    description = "Reference implementation of Vectorization of Line Drawings via PolyVector Fields";
    homepage = "https://github.com/bmpix/PolyVectorization";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    mainProgram = "polyvector_thing";
    skip.ci = stdenv.isDarwin;
    broken = true;
  };
}
