{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "nats-static";
  version = "0.0.7";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "nats-static";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9nPKUIlgxR2u8qeeT06BFWexkScPabFgt66qOOqYpwM=";
  };

  vendorHash = "sha256-/BvXCA/+ATOFgdLCEt4nQDRtNCV+Zc5QeiEip58rIn4=";

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
