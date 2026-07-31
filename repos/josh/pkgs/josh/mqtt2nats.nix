{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "mqtt2nats";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "mqtt2nats";
    tag = "v${finalAttrs.version}";
    hash = "sha256-da5yTihCYgjeBVOUXPoybPY0LEbA+EtytxFB+XVSnzw=";
  };

  vendorHash = "sha256-R5ogsNHxVv/siwimAi5jA1iEMGuLpuLXG2Ni/2ZUrQE=";

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
