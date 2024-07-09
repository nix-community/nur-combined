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
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "rmqtt";
    repo = "rmqtt";
    rev = version;
    hash = "sha256-W6EUzRcy8aurZiNf3C1xsPV9v13fc9+qp0G4XAFxJR4=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "ntex-0.3.22" = "sha256-tJak2elnYrC7Y4LjNC4nk113ru5RZjtzSDDsLTqxKGo=";
      "ntex-mqtt-0.6.23" = "sha256-d+G2lPV5vf01jlDWRd+NyUUqebLrZi/OcYP8VtiF6pg=";
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
  };
}
