{
  lib,
  rustPlatform,
  fetchFromGitea,
  versionCheckHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "magothy";
  version = "0-unstable-2025-06-22";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "serebit";
    repo = "magothy";
    rev = "ac58175712d129f63e0f77f67ba4961ad3459b53";
    hash = "sha256-xGQqC7B7lNSHuJFgKj5srcDLKqA1Fc+TG21oPuyiifQ=";
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
