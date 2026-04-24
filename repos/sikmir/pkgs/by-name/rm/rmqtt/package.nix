{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  pkg-config,
  protobuf,
  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rmqtt";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "rmqtt";
    repo = "rmqtt";
    tag = finalAttrs.version;
    hash = "sha256-7lJs1HtQCtS4MtNim9Aho7zc9H0goBGrCl91q0O1Zq4=";
  };

  cargoHash = "sha256-htn+baGbvg920bYq6cCqJ/7ORwRNebSgFIJaRSJjZUQ=";

  nativeBuildInputs = [
    cmake
    pkg-config
    protobuf
  ];

  buildInputs = [ openssl ];

  meta = {
    description = "MQTT Broker";
    homepage = "https://github.com/rmqtt/rmqtt";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
