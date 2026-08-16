{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "nats-static";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "nats-static";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QIFE0ZwFsvKS03uctABZMtUwLZu4g9jRW0MOQg/duZA=";
  };

  vendorHash = "sha256-M3feEnza10nFmPC8w9rUHaaESDHZl5kI4p4IxJCpSNs=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      command = "nats-static version";
      inherit (finalAttrs) version;
    };
  };

  meta = {
    description = "Serve static files from a NATS JetStream object store over HTTP";
    homepage = "https://github.com/josh/nats-static";
    license = lib.licenses.mit;
    mainProgram = "nats-static";
  };
})
