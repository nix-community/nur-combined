{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  check,
  libconfig,
  libiio,
  volk,
  protobufc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sdr-modem";
  version = "1.0.129";

  src = fetchFromGitHub {
    owner = "dernasherbrezon";
    repo = "sdr-modem";
    tag = finalAttrs.version;
    hash = "sha256-27Kz7xvgb6h/TBohhrgO3D4/eCBLkqYyHDMnmITM88s=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    check
    libconfig
    libiio
    volk
    protobufc
  ];

  installPhase = ''
    install -Dm755 sdr_modem -t $out/bin
    install -Dm644 $src/src/resources/config.conf -t $out/etc
  '';

  meta = {
    description = "Modem based on software defined radios";
    homepage = "https://github.com/dernasherbrezon/sdr-modem";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    broken = stdenv.isDarwin; # libiio
  };
})
