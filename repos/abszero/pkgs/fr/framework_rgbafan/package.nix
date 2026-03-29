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
  version = "0-unstable-2026-03-28";

  src = fetchFromGitHub {
    owner = "jazz-g";
    repo = "framework_rgbafan";
    rev = "004c1b878e8f5b3faffb8fb1b93536372a6fe2bb";
    hash = "sha256-pJkXEHt/vQ1LP3S6ZfI/EpyOJ0KxLeVLYxFnyMZT40o=";
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
