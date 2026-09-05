{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  protobuf,
  pkg-config,
  cacert,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "konnect";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "mixelpixx";
    repo = "Konnect";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6rcfSGqa+SO7bH5a23Q2XpI7UhzNKAowK+IM0xh8LDo=";
  };

  cargoHash = "sha256-+VhPB3/8bCK8GK6ackNt9nprAR266dM+hEb5hDeAN5s=";

  nativeBuildInputs = [
    cmake
    protobuf
    pkg-config
  ];

  nativeCheckInputs = [ cacert writableTmpDirAsHomeHook ];

  PROTOC = "${protobuf}/bin/protoc";
  PROTOC_INCLUDE = "${protobuf}/include";

  cargoBuildFlags = [
    "-p"
    "konnect"
    "--bin"
    "konnect"
  ];

  meta = {
    description = "Native KiCad 10 MCP plugin that lets AI assistants design schematics and PCBs";
    homepage = "https://github.com/mixelpixx/Konnect";
    changelog = "https://github.com/mixelpixx/Konnect/blob/v${finalAttrs.version}/README.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "konnect";
    platforms = lib.platforms.linux;
  };
})
