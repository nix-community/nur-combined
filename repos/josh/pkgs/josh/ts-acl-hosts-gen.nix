{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "ts-acl-hosts-gen";
  version = "0.3.0-unstable-2025-07-29";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "ts-acl-hosts-gen";
    rev = "3de97898281aba9a8cf043b35190d2b2ed3743cc";
    hash = "sha256-kMvzPVtbaQPfe1lAaVKb5oOYbX5B9/92KxpikUUAUB0=";
  };

  vendorHash = "sha256-VFOJ/mWHR7Y4pcjkewYH1/Heg1YqerluUq9SXkGIRRQ=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    help =
      runCommand "test-ts-acl-hosts-gen-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; }
        ''
          ts-acl-hosts-gen --help
          touch $out
        '';
  };

  meta = {
    description = "Generate Tailscale hosts policy from existing nodes";
    homepage = "https://github.com/josh/ts-acl-hosts-gen";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "ts-acl-hosts-gen";
  };
})
