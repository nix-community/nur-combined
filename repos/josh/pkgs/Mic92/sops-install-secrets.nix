{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "sops-install-secrets";
  version = "assets-unstable-2026-09-19";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "sops-nix";
    rev = "166fc0d3f4fcd0dfc9af102ba8e85fa5dd04e5f7";
    hash = "sha256-/Ql9UE21iDwOU/JdPV20yZtaMpGf+iD2EhIA1aAi540=";
  };

  vendorHash = "sha256-ppcmy/WYnPdD1BuesRX1JpMtZDDLN7wm/ohJkEqL2jo=";

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
