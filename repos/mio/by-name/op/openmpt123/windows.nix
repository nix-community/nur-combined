{
  lib,
  fetchFromGitHub,
  pkgsCross,
}:

let
  mingwStdenv = pkgsCross.mingwW64.stdenv;
in
mingwStdenv.mkDerivation (finalAttrs: {
  pname = "openmpt123-windows";
  version = "0.8.10";

  src = fetchFromGitHub {
    owner = "OpenMPT";
    repo = "openmpt";
    rev = "libopenmpt-${finalAttrs.version}";
    hash = "sha256-N7EZqfM9U+1F0R4S0kT6MTbWxVTH2T7NE7nuKEaKl5s=";
  };

  enableParallelBuilding = true;
  dontConfigure = true;

  # The upstream Makefile's mingw-w64 config already disables every optional
  # library for cross builds (zlib, mpg123, ogg/vorbis, portaudio, pulse, SDL2,
  # sndfile, FLAC), leaving the built-in decoders, so this needs no extra
  # packages. A static libopenmpt keeps openmpt123.exe self-contained instead of
  # needing libopenmpt.dll next to it.
  buildPhase = ''
    runHook preBuild
    make -j$NIX_BUILD_CORES \
      CONFIG=mingw-w64 WINDOWS_ARCH=amd64 \
      OPENMPT123=1 EXAMPLES=0 TEST=0 \
      STATIC_LIB=1 SHARED_LIB=0 DYNLINK=0 \
      LDFLAGS=-static \
      VERBOSE=1
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/openmpt123.exe "$out/share/openmpt123/openmpt123.exe"
    install -Dm644 LICENSE "$out/share/doc/openmpt123/LICENSE"
    runHook postInstall
  '';

  # hostPlatform is Windows when cross-compiling; omit platforms so nixpkgs
  # does not reject this nested drv during the Linux/Darwin wrapper eval.
  meta = {
    description = "openmpt123 Windows build (MinGW cross-compiled)";
    homepage = "https://lib.openmpt.org/libopenmpt/";
    license = lib.licenses.bsd3;
  };
})
