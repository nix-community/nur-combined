{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "iso15765-canbus";
  version = "0-unstable-2024-01-17";

  src = fetchFromGitHub {
    owner = "devcoons";
    repo = "iso15765-canbus";
    tag = finalAttrs.version;
    hash = "sha256-KdVw8JhJsqa+n3ELnTojHV/37Wfb1A2a7fSbBsTkJgI=";
  };

  makeFlags = [
    "CC:=$(CC)"
    "CXX:=$(CXX)"
  ];

  installPhase = ''
    install -Dm644 lib/lib_iqueue.h src/lib_iso15765.h -t $out/include
    install -Dm644 bin/libiso15765.so.0.1 -t $out/lib
  '';

  meta = {
    description = "Implementation of ISO15765-2 in C";
    homepage = "https://github.com/devcoons/iso15765-canbus";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
