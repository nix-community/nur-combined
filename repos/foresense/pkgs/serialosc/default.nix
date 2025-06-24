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
  version = "1.4.6";

  src = fetchFromGitHub {
    owner = "monome";
    repo = "serialosc";
    rev = "v${version}";
    hash = "sha256-pONOr2JQCpbKKAnpMyHAaUSmsf48pxINZRKVWJ1q9mQ=";
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
