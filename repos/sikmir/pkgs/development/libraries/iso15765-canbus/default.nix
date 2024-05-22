{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "iso15765-canbus";
  version = "0-unstable-2024-01-17";

  src = fetchFromGitHub {
    owner = "devcoons";
    repo = "iso15765-canbus";
    rev = version;
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

  meta = with lib; {
    description = "Implementation of ISO15765-2 in C";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
