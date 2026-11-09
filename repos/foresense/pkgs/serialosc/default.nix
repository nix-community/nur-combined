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
  version = "1.4.8";

  src = fetchFromGitHub {
    owner = "monome";
    repo = "serialosc";
    rev = "v${version}";
    hash = "sha256-WI9Ok4JDSUOvwN50KYjh0yov2l7Fk6eX7tC7NSJ6HiU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [ udev ];

  installPhase = ''
    runHook preInstall

    install -D -t $out/bin ./bin/{serialoscd,serialosc-device,serialosc-detector}

    runHook postInstall
  '';

  meta = {
    description = "Multi-device, bonjour-capable monome OSC server";
    homepage = "https://github.com/monome/serialosc";
    license = lib.licenses.mit;
    mainProgram = "serialoscd";
    platforms = lib.platforms.all;
  };
}
