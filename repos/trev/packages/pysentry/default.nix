{
  buildRustPackage ? rustPlatform.buildRustPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:

buildRustPackage (finalAttrs: {
  pname = "pysentry";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "nyudenkov";
    repo = "pysentry";
    rev = "v${finalAttrs.version}";
    hash = "sha256-COxRlPM0pU/O2+T1yxkzRU3B2NtPJYMGlWRWJr17qE4=";
  };

  cargoHash = "sha256-8fGybYWs5wVgvFw20i2J4Hb/Z36t4xnjb09w5i/fUZM=";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      finalAttrs.pname
    ];
  };

  meta = {
    description = "Scans your Python dependencies for known security vulnerabilities";
    mainProgram = "pysentry";
    homepage = "https://github.com/nyudenkov/pysentry";
    changelog = "https://github.com/nyudenkov/pysentry/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
