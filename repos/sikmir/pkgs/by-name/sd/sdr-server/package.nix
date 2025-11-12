{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  check,
  libconfig,
  rtl-sdr,
  volk,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sdr-server";
  version = "1.1.26";

  src = fetchFromGitHub {
    owner = "dernasherbrezon";
    repo = "sdr-server";
    tag = finalAttrs.version;
    hash = "sha256-knZHFErORSwqQV3G1ynRwtnylYfeE7qX4m4SZN57Tf8=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    check
    libconfig
    rtl-sdr
    volk
    zlib
  ];

  installPhase = ''
    install -Dm755 sdr_server -t $out/bin
    install -Dm644 $src/src/resources/config.conf -t $out/etc
  '';

  meta = {
    description = "High performant TCP server for rtl-sdr";
    homepage = "https://github.com/dernasherbrezon/sdr-server";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
