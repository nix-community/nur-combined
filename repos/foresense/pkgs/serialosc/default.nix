{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  udev,
}:

stdenv.mkDerivation rec {
  pname = "serialosc";
  version = "1.4.5";

  src = fetchFromGitHub {
    owner = "monome";
    repo = "serialosc";
    rev = "v${version}";
    hash = "sha256-4B5DHmymEXRf8blvNP8xraENqbCw9vhgQRsnbZD/gPU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [ udev ];

  installPhase = ''
    install -D -t $out/bin ./bin/{serialoscd,serialosc-device,serialosc-detector}
  '';

  meta = {
    description = "Multi-device, bonjour-capable monome OSC server";
    homepage = "https://github.com/monome/serialosc";
    license = lib.licenses.mit;
    mainProgram = "serialoscd";
    platforms = lib.platforms.all;
  };
}
