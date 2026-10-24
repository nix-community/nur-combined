{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "sops-install-secrets";
  version = "assets-unstable-2026-10-24";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "sops-nix";
    rev = "442449fa7b1fe6c692d0103ac9fc8f9e82931cf3";
    hash = "sha256-KV+CaZX7QS0hcdKxwGKehDb1jmUgx6lbkTPpaoIW5Nw=";
  };

  vendorHash = "sha256-/7qWP61RK61qgEaEyoOVveWw7S2LpoKJxC9S4dLu6Lo=";

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
