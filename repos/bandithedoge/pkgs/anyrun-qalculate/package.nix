{
  fetchFromGitLab,
  lib,
  nix-update-script,
  rustPlatform,

  anyrun,
}:
rustPlatform.buildRustPackage {
  pname = "anyrun-qalculate";
  version = "0-unstable-2025-03-06";
  src = fetchFromGitLab {
    owner = "udragg";
    repo = "anyrun-qalculate";
    rev = "88253337db93160302b063aee7db580f48612e6a";
    hash = "sha256-FQ793hPKreCeV8YMSBmqKu0eQBcrA1fTx9wVC50NSdU=";
  };

  cargoHash = "sha256-kTXbi8aAGh7S9ZJvnSW1+QvryAns1P6X0QRKFNjdI6M=";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Anyrun plugin adding Qalculate! support";
    homepage = "https://gitlab.com/udragg/anyrun-qalculate";
    license = lib.licenses.gpl3Plus;
    inherit (anyrun.meta) platforms;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
