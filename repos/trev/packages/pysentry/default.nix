{
  buildRustPackage ? rustPlatform.buildRustPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:

buildRustPackage (finalAttrs: {
  pname = "pysentry";
  version = "0.4.7";

  src = fetchFromGitHub {
    owner = "nyudenkov";
    repo = "pysentry";
    rev = "v${finalAttrs.version}";
    hash = "sha256-CKTW6neah8pT+S4exMDXJDfRTwZ++SxXZGZlIUo+IY8=";
  };

  cargoHash = "sha256-2C22rhay8hVzqO4g1fLKHqIMsbLyhGIaDIw9R6sPXD0=";

  preCheck = ''
    export HOME="$TMPDIR"
  '';

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
