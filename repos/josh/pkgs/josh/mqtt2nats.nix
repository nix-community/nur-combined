{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
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

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "Relay MQTT messages to NATS";
    homepage = "https://github.com/josh/mqtt2nats";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "mqtt2nats";
  };
})
