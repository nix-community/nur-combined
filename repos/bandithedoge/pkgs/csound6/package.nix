{
  sources,

  lib,
  stdenv,
  ninja,
  cmake,
  libsndfile,
  flex,
  bison,
  alsa-lib,
}:
stdenv.mkDerivation {
  inherit (sources.csound6) pname version src;

  nativeBuildInputs = [
    cmake
    ninja
    flex
    bison
  ];

  buildInputs = [
    libsndfile
    alsa-lib
  ];

  NIX_CFLAGS_COMPILE = [ "-Wno-template-body" ];

  meta = {
    description = "Sound design, audio synthesis, and signal processing system, providing facilities for music composition and performance on all major operating systems and platforms";
    homepage = "https://csound.com";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin;
    mainProgram = "csound";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
