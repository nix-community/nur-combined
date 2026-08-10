{
  sources,

  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  inherit (sources.clap-validator) pname version src;
  cargoLock = sources.clap-validator.cargoLock."Cargo.lock";

  checkFlags = [
    "--skip=fuzz_clack_effect"
    "--skip=fuzz_clack_synth"
    "--skip=validate_clack_effect"
    "--skip=validate_clack_synth"
  ];

  meta = {
    description = "Automatic CLAP validation and testing tool";
    homepage = "https://github.com/free-audio/clap-validator";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "clap-validator";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
