{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "sops-install-secrets";
  version = "assets-unstable-2026-10-26";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "sops-nix";
    rev = "60182817ee048ac94b4c68ea76d5ef2e8aac730d";
    hash = "sha256-Y/JIHTnMlOabDfyaSBubWGLDIVGihLEUuoMhFvQKaDo=";
  };

  vendorHash = "sha256-ZRRW1WPoszoZaiARVKNjnM6tz8eBXeVm5sHUxRWOcDw=";

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
