{
  lib,
  stdenv,
  python3,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "esp32knife";
  version = "0-unstable-2024-05-16";

  src = fetchFromGitHub {
    owner = "BlackVS";
    repo = "esp32knife";
    rev = "ec38a7bf2b5be96658ff288dbc024911dff4e8b6";
    hash = "sha256-M2WTYayq0v+UUYCerBxB7baMD8GCWHJXZ+kDeq7rBCc=";
  };

  nativeBuildInputs = [
    (python3.withPackages (py: [
      py.pyserial
      py.ecdsa
      py.reedsolo
      py.cryptography
      py.hexdump
    ]))
  ];

  prePatch = ''
    patchShebangs *.py
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 -t $out/bin/ esp*.py

    runHook postInstall
  '';

  meta = {
    description = "Tools for ESP32 firmware dissection";
    homepage = "https://github.com/BlackVS/esp32knife";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "esp32knife";
    platforms = lib.platforms.all;
  };
}
