{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  check,
  libconfig,
  librtlsdr,
  volk,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sdr-server";
  version = "1.1.21";

  src = fetchFromGitHub {
    owner = "dernasherbrezon";
    repo = "sdr-server";
    rev = finalAttrs.version;
    hash = "sha256-7X8woFT0PoIfnwcBwhPRJ4ZijtlZDBsCrTUhxbozrjI=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    check
    libconfig
    librtlsdr
    volk
    zlib
  ];

  installPhase = ''
    install -Dm755 sdr_server -t $out/bin
    install -Dm644 $src/src/resources/config.conf -t $out/etc
  '';

  meta = {
    description = "High performant TCP server for rtl-sdr";
    inherit (finalAttrs.src.meta) homepage;
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
