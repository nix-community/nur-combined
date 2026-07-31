{
  buildRustPackage ? rustPlatform.buildRustPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:

buildRustPackage (finalAttrs: {
  pname = "pysentry";
  version = "0.4.9";

  src = fetchFromGitHub {
    owner = "nyudenkov";
    repo = "pysentry";
    rev = "v${finalAttrs.version}";
    hash = "sha256-KpcDqfHZUQV0gP4Hi+C6rkaQtxTVyzuXSfDN0Bembgc=";
  };

  cargoHash = "sha256-fobFW16CKU0jRdZp7aPI06QU9qL7waIDg2hkue/GRBw=";

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
