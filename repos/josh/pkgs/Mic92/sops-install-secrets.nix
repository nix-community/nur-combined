{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "sops-install-secrets";
  version = "assets-unstable-2026-11-09";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "sops-nix";
    rev = "fe7b4228405aeac2ce7192c2049a6e2bc8637082";
    hash = "sha256-Ivif/kuD68yEOKcZZG3zSwNMFUuIgzUgeJuzcHrQy+8=";
  };

  vendorHash = "sha256-0tialzbrVJc0xveIJHU3VuqpZE0Jp7GASGGpkbY2c8c=";

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
