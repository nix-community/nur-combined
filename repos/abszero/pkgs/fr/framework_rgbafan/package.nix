{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  systemdLibs,

  nLeds ? 8,
}:

rustPlatform.buildRustPackage {
  pname = "framework_rgbafan";
  version = "0-unstable-2025-12-09";

  src = fetchFromGitHub {
    owner = "jazz-g";
    repo = "framework_rgbafan";
    rev = "d37b5acc2acfa6bf49ee73c968589f3545f0c89d";
    hash = "sha256-hJY1sKwGbKxPL/kP9oo6VNvIYfgdDkgNJg8Hm+yJFW0=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "framework_lib-0.4.5" = "sha256-pPYV+a0sLLxdSjjO+qaRK+ddGLXzpOvUx3I60Ccd8gg=";
      "redox_hwio-0.1.6" = "sha256-knLIZ7yp42SQYk32NGq3SUGvJFVumFhD64Njr5TRdFs=";
      "smbios-lib-0.9.1" = "sha256-3L8JaA75j9Aaqg1z9lVs61m6CvXDeQprEFRq+UDCHQo=";
    };
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ systemdLibs.dev ]; # For libudev.pc

  patchPhase = ''
    substituteInPlace src/consts.rs --replace-fail "N_LEDS: u8 = 8" "N_LEDS: u8 = ${toString nLeds}"
  '';

  meta = {
    description = "Music visualizer (mpd) and simple animations on the Framework Desktop Fan";
    homepage = "https://github.com/jazz-g/framework_rgbafan";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ weathercold ];
    mainProgram = "framework_rgbafan";
  };
}
