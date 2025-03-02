{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
let
  hubproxy = buildGoModule rec {
    pname = "hubproxy";
    version = "0-unstable-2025-02-26";

    src = fetchFromGitHub {
      owner = "cased";
      repo = "hubproxy";
      rev = "be0502efb3211e25077053acea542bb37a147b9e";
      hash = "sha256-Cgs4lfD57qxAn9mOPMu9sv0Ie/rkrKDGWqn73BbpsaY=";
    };

    vendorHash = "sha256-5LHi4dWcfWJNCABRIQPAFivuM6ldCOC0KV0RAv/DsmI=";

    meta = {
      description = "A proxy for better github webhooks";
      homepage = "https://github.com/cased/hubproxy";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
      mainProgram = "hubproxy";
    };
  };
in
hubproxy.overrideAttrs (
  finalAttrs: _previousAttrs:
  let
    hubproxy = finalAttrs.finalPackage;
  in
  {
    passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

    passthru.tests = {
      help =
        runCommand "test-hubproxy-help"
          {
            __structuredAttrs = true;
            nativeBuildInputs = [ hubproxy ];
          }
          ''
            hubproxy --help
            touch $out
          '';
    };
  }
)
