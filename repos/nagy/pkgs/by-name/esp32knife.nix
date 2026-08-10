{
  lib,
  stdenv,
  python3,
  esptool,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "esp32knife";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "BlackVS";
    repo = "esp32knife";
    rev = "v2.0.1";
    hash = "sha256-uXZugqhGFZwCYyqnjiuWLsg33bsYrEzBZtpuX4mP4HI=";
  };

  nativeBuildInputs = [
    (python3.withPackages (py: [
      py.hexdump
      (py.toPythonModule esptool)
      (py.callPackage ../python3-packages/makeelf.nix { })
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
