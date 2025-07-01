{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "ts-acl-hosts-gen";
  version = "0.2.0-unstable-2025-02-21";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "ts-acl-hosts-gen";
    rev = "87c93b613fdbbdc01438d887a2e7113993c60326";
    hash = "sha256-mdIBkxZTjFUZ/aw3HyolQxtKJ+3BYV51NCE0Rb3L9YU=";
  };

  vendorHash = "sha256-YmaWaQ4sOF5bQFOv3MNsUsOFQaBgYhEO0JR/x5R+gf4=";

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
