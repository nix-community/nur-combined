{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "nats-static";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "nats-static";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UkIDzC+b/p13Nc3kGd+CRyXxYmAxeRG3OQIHHV0ihk4=";
  };

  vendorHash = "sha256-83qwiDPGY2HKpaU4ZvkCBxjqxvgoEGZYH+3op9kCTqw=";

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
