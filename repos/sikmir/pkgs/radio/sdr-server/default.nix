{ lib, stdenv, fetchFromGitHub, cmake, pkg-config, check, libconfig, librtlsdr, volk, zlib }:

stdenv.mkDerivation (finalAttrs: {
  pname = "sdr-server";
  version = "1.1.12";

  src = fetchFromGitHub {
    owner = "dernasherbrezon";
    repo = "sdr-server";
    rev = finalAttrs.version;
    hash = "sha256-LFXMWsZM2bt8Ew1g3KMakLWgHihrkAivL0QQ+XKNtos=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ check libconfig librtlsdr volk zlib ];

  installPhase = ''
    install -Dm755 sdr_server -t $out/bin
    install -Dm644 $src/src/resources/config.conf -t $out/etc
  '';

  meta = with lib; {
    description = "High performant TCP server for rtl-sdr";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.gpl2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
