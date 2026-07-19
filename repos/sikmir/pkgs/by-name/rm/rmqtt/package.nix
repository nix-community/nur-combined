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
  version = "0.22.0";

  src = fetchFromGitHub {
    owner = "rmqtt";
    repo = "rmqtt";
    tag = finalAttrs.version;
    hash = "sha256-CLFEIhkZ/0mbSkjY2JH/eIKIogm/cwW6hbzTjFqLOOY=";
  };

  cargoHash = "sha256-/TXU8JOcgaPHRGxHJ98B4RDO6+jXulJcQdE3uOg1t+8=";

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
