{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  darwin,
  protobuf,
}:

rustPlatform.buildRustPackage rec {
  pname = "rmqtt";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "rmqtt";
    repo = "rmqtt";
    rev = version;
    hash = "sha256-EPHiwDct8abzzYUj5egKf93yIrzFxoYDcH6ki4bZfGw=";
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

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  meta = {
    description = "MQTT Broker";
    homepage = "https://github.com/rmqtt/rmqtt";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    broken = true; # failed to get `ahash` as a dependency
  };
}
