{
  lib,
  rustPlatform,
  fetchFromGitea,
  versionCheckHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "magothy";
  version = "0-unstable-2025-06-17";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "serebit";
    repo = "magothy";
    rev = "577e6b211c74216b7fa29b4a425819124b4a3bef";
    hash = "sha256-SaVN/52oa/tMPDCkd6cuK/7Eri6e4wtxxtXL5/bablQ=";
  };

  cargoHash = "sha256-5l306byTAmpGjYs7iPZGWGSQt5axt9h2o1cKEyIjsKk=";

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  # Does not have a proper version yet ("0.0.0").
  dontVersionCheck = true;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    mainProgram = "magothy";
    description = "A hardware profiling application for Linux";
    homepage = "https://codeberg.org/serebit/magothy";
    license = with lib.licenses; [
      asl20
      cc0
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
