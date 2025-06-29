{
  lib,
  rustPlatform,
  fetchFromGitHub,
  protobuf,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rmqtt";
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "rmqtt";
    repo = "rmqtt";
    tag = finalAttrs.version;
    hash = "sha256-5drl63QwbcprLIRyaKl3/QUOOoG+uRZd6qxDX9yOLYQ=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "ntex-0.4.1" = "sha256-nt/nLO7oIpE7EvxY2WseiGZH3U6Gw1jaJabPW76RCwk=";
      "ntex-mqtt-0.7.2" = "sha256-ijHb37ZpwcfaHnVcB6moqFpCFjU8Jhiv8pxfARgTXkY=";
    };
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [ protobuf ];

  meta = {
    description = "MQTT Broker";
    homepage = "https://github.com/rmqtt/rmqtt";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    broken = true; # failed to get `ahash` as a dependency
  };
})
