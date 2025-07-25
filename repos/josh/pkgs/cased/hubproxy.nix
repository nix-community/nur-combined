{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "hubproxy";
  version = "1.0.0-unstable-2025-06-08";

  src = fetchFromGitHub {
    owner = "cased";
    repo = "hubproxy";
    rev = "98d5b850eb695d4becbf5abad483a380a6f6da65";
    hash = "sha256-H+Zm1rt8r3MOVJ2rf1UFTXO1BfW3tpj7oaDYcdK1Xag=";
  };

  vendorHash = "sha256-uEsF3N8VctXoXpPohqFkbLpLAJX+65KMvUlTNNKRTXo=";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    help = runCommand "test-hubproxy-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; } ''
      hubproxy --help
      touch $out
    '';
  };

  meta = {
    description = "A proxy for better github webhooks";
    homepage = "https://github.com/cased/hubproxy";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "hubproxy";
  };
})
