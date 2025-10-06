{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  protobuf,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rmqtt";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "rmqtt";
    repo = "rmqtt";
    tag = finalAttrs.version;
    hash = "sha256-9FhITQOnA4zZCYtBZJSmwf5st2wnGSi8MukiQ3bmTcU=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    cmake
    protobuf
  ];

  meta = {
    description = "MQTT Broker";
    homepage = "https://github.com/rmqtt/rmqtt";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    broken = true; # error[E0603]: function `get_slot` is private
  };
})
