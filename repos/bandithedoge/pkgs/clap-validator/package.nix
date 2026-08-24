{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "clap-validator";
  version = "0.4.1";
  src = fetchFromGitHub {
    owner = "free-audio";
    repo = "clap-validator";
    rev = finalAttrs.version;
    hash = "sha256-4GmmZIMRoPUEbsT34iCaOWRhYmhMonF9BXnc/rFQV0M=";
  };

  cargoHash = "sha256-m6VebZM8jVm22Xk8URpHF+UAHOJWYC74Ha3bpFuz1VU=";

  checkFlags = [
    "--skip=fuzz_clack_effect"
    "--skip=fuzz_clack_synth"
    "--skip=validate_clack_effect"
    "--skip=validate_clack_synth"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Automatic CLAP validation and testing tool";
    homepage = "https://github.com/free-audio/clap-validator";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "clap-validator";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
