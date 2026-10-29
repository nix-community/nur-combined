{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "mqtt2nats";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "mqtt2nats";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CuQtqVRpY5bVDdrteT7kuN3MYpQ9wsznLkJf5sX73dY=";
  };

  vendorHash = "sha256-zygrgfNFGt6ol72rzn/gsgSwIzwfhybqE5DwQHYRJqs=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    help = runCommand "test-mqtt2nats-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; } ''
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
