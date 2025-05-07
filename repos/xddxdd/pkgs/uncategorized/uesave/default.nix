{
  sources,
  lib,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage rec {
  inherit (sources.uesave) pname version src;

  cargoHash = "sha256-QGhaaBvxKYnljrkCCcFZLALppvM15c8Xtn36SecaNJ8=";
  useFetchCargoVendor = true;

  doCheck = false;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/${meta.mainProgram}";

  meta = {
    changelog = "https://github.com/trumank/uesave-rs/releases/tag/v${version}";
    mainProgram = "uesave";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Library for reading and writing Unreal Engine save files (commonly referred to as GVAS)";
    homepage = "https://github.com/trumank/uesave-rs";
    license = lib.licenses.mit;
  };
}
