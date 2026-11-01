{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  protobuf,
  pkg-config,
  cacert,
  writableTmpDirAsHomeHook,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "konnect";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "mixelpixx";
    repo = "Konnect";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8grXUwq5L25TFBSylB36yAaEPfNV7dos9kf+1UH6xDg=";
  };

  cargoHash = "sha256-q/cWeNORFjPp3YFoiICGQVGolL7hd+oCu3Fvj+8IhUc=";

  nativeBuildInputs = [
    cmake
    protobuf
    pkg-config
  ];

  nativeCheckInputs = [
    cacert
    writableTmpDirAsHomeHook
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

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
