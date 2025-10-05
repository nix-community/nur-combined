{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "iso15765-canbus";
  version = "2024-12-11";

  src = fetchFromGitHub {
    owner = "devcoons";
    repo = "iso15765-canbus";
    tag = finalAttrs.version;
    hash = "sha256-qLfrwDUNoFUo58bRudAdkrE5GsREyU/lWkVryX1K2fk=";
  };

  nativeBuildInputs = [ cmake ];

  installPhase = ''
    install -Dm644 ../lib/lib_iqueue.h ../src/lib_iso15765.h -t $out/include
    install -Dm644 build/*.a -t $out/lib
  '';

  meta = {
    description = "Implementation of ISO15765-2 in C";
    homepage = "https://github.com/devcoons/iso15765-canbus";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
