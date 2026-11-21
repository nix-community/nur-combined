{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  systemdLibs,

  nLeds ? 8,
}:

rustPlatform.buildRustPackage (final: {
  pname = "framework_rgbafan";
  version = "0-unstable-2026-11-19";

  src = fetchFromGitHub {
    owner = "jazz-g";
    repo = "framework_rgbafan";
    rev = "4314e22f988cf774b0abc9e874c8829acf66659a";
    hash = "sha256-l1fpg43jmhYsqG7JSlot7cG7ShLCRzhRCsdWpJ9ec1s=";
  };

  cargoLock = {
    lockFile = "${final.src}/Cargo.lock";
    outputHashes = {
      "framework_lib-0.4.5" = "sha256-pPYV+a0sLLxdSjjO+qaRK+ddGLXzpOvUx3I60Ccd8gg=";
      "redox_hwio-0.1.6" = "sha256-knLIZ7yp42SQYk32NGq3SUGvJFVumFhD64Njr5TRdFs=";
      "smbios-lib-0.9.1" = "sha256-3L8JaA75j9Aaqg1z9lVs61m6CvXDeQprEFRq+UDCHQo=";
    };
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ systemdLibs.dev ]; # For libudev.pc

  patchPhase = ''
    substituteInPlace src/consts.rs \
      --replace-fail "N_LEDS: usize = 8" "N_LEDS: usize = ${toString nLeds}" \
      --replace-fail "RAINBOW: [RgbS; N_LEDS]" "RAINBOW: [RgbS; 8]"
    substituteInPlace src/effects.rs --replace-fail "SPINFADE_SCALES: [f32; N_LEDS]"  "SPINFADE_SCALES: [f32; 8]"
  '';

  meta = {
    description = "Music visualizer (mpd) and simple animations on the Framework Desktop Fan";
    homepage = "https://github.com/jazz-g/framework_rgbafan";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ weathercold ];
    mainProgram = "framework_rgbafan_daemon";
  };
})
