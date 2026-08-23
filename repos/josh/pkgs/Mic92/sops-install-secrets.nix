{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "sops-install-secrets";
  version = "assets-unstable-2026-08-13";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "sops-nix";
    rev = "a8627b21b9107c5711c96b84f32a9a4b3d45295f";
    hash = "sha256-gkig4nPi1CWc4Z50GBsjE4ygSE7hMpl/TwID2an2Cck=";
  };

  vendorHash = "sha256-rdiuCTl92biIdCdRouCbqUgjqM50Gi/oY3k5oOWKd9E=";

  subPackages = [ "pkgs/sops-install-secrets" ];

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch=master" ];
  };

  passthru.tests = {
    check-empty-manifest =
      runCommand "test-sops-install-secrets-check-empty-manifest"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          echo '{}' >manifest.json
          sops-install-secrets -check-mode=manifest manifest.json
          sops-install-secrets -check-mode=sopsfile manifest.json
          touch $out
        '';
  };

  meta = {
    description = "Atomic secret provisioning based on sops";
    homepage = "https://github.com/Mic92/sops-nix";
    license = lib.licenses.mit;
    mainProgram = "sops-install-secrets";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
