{
  lib,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  paho-mqtt-c,
  pkg-config,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "systemd2mqtt";
  version = "0-unstable-2024-05-01";

  src = fetchFromGitHub {
    owner = "arcnmx";
    repo = "systemd2mqtt";
    rev = "7cd09aa52685fa1a3d18f36b039754a149b4d941";
    hash = "sha256-An97O4aa2yw80jYY9eucFnlBuVSYU8JAszpWjfWgju8=";
  };

  cargoHash = "sha256-Vl8ccyB35KeCZjOA5IUw/zYhYJGUuwVCJFtqOkZmvVo=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    paho-mqtt-c
  ];

  meta = {
    description = "Expose systemd services to MQTT";
    homepage = "https://github.com/arcnmx/systemd2mqtt";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "systemd2mqtt";
  };
})
