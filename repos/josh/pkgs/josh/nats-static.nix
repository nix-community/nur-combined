{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "nats-static";
  version = "0.0.5";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "nats-static";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/DmwmR/ijXpuZHFssOaLSHJV0zskc94LEcy+zLRcd78=";
  };

  vendorHash = "sha256-UTfUDGOUKlxW84O3hN2pj+ti6eY25Yx93pXumDoXQaI=";

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
