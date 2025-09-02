{
  sources,
  lib,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uesave";
  inherit (sources.uesave-0_3_0) version src;

  cargoHash = "sha256-sdXr+z8wxEB3qqRB+d9uFbEyX6LEYoHANxrzfdfC3+0=";

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.meta.mainProgram}";

  meta = {
    mainProgram = "uesave";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Library for reading and writing Unreal Engine save files (commonly referred to as GVAS), older version that works with Palworld";
    homepage = "https://github.com/trumank/uesave-rs";
    license = lib.licenses.mit;
  };
})
