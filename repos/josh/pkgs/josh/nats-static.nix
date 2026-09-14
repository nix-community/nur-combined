{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "nats-static";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "nats-static";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Zga7q6EHIksbqcjyWroxKNjJBdIdufxggNP8Rk1Myto=";
  };

  vendorHash = "sha256-gL+sb8qNNhTY6ljstBeUMYA/qgy6XKdxXk9++jQg/mc=";

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
