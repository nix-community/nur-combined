{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "mqtt2nats";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "mqtt2nats";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NK032XKRyEWdm9fsY9gp2DpmpBr7f9PHCGzoAwZ6w/0=";
  };

  vendorHash = "sha256-5g3kJcIODHt7CFs0nrynJEMh3vELfIEM0z49c6B6h30=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    help =
      runCommand "test-mqtt2nats-help"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          mqtt2nats --help
          touch $out
        '';
  };

  meta = {
    description = "Relay MQTT messages to NATS";
    homepage = "https://github.com/josh/mqtt2nats";
    license = lib.licenses.mit;
    mainProgram = "mqtt2nats";
  };
})
