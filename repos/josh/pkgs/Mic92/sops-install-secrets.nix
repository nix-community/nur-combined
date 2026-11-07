{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "sops-install-secrets";
  version = "assets-unstable-2026-11-06";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "sops-nix";
    rev = "89a234ce2daf6e568a7d4b4fe250afdd23d84e20";
    hash = "sha256-ZlE4BtMjWhfC6rFXLO9Qimn36Ene1INqCgKDDvazjhc=";
  };

  vendorHash = "sha256-DSbDef+a9LKarOAnKt9/ncjieDpvUNV3I8tazPevJlg=";

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
        { nativeBuildInputs = [ finalAttrs.finalPackage ]; }
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
