{
  buildRustPackage ? rustPlatform.buildRustPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:

buildRustPackage (finalAttrs: {
  pname = "pysentry";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "nyudenkov";
    repo = "pysentry";
    rev = "v${finalAttrs.version}";
    hash = "sha256-IATeghqhEKAQM2qyVeyUYd3LJkgxHShcgEqHET8xZwU=";
  };

  cargoHash = "sha256-yL2yM/oIMeIpBTWj2ldf30fCkLV+1F+VD9pOi0pceBM=";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      "${finalAttrs.pname}"
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
