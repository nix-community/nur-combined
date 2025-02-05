{ lib, stdenv, fetchFromGitHub, hidapi, pkg-config, ... }:
stdenv.mkDerivation rec {
  pname = "SonixFlasherC";
  version = "2.0.7";

  src = fetchFromGitHub {
    owner = "SonixQMK";
    repo = pname;
    rev = version;
    hash = "sha256-ADcTzSe8aQJRCvDhKfaf/C8V2MugQG89swhRPVCvcIQ=";
  };

  buildInputs = [ pkg-config hidapi ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp sonixflasher $out/bin/${pname}
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/SonixQMK/SonixFlasherC";
    description = "A CLI-based flasher for Sonix SN32F2xx MCUs.";
    license = with licenses; [ gpl3 ];
    platforms = [ "x86_64-linux" ];
  };
}
