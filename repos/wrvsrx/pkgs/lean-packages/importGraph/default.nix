{
  stdenv,
  lean4,
  lakeSetupHook,
  writeText,
  Cli,
  lib,
  source,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;
  env.NIX_LAKE_MANIFEST_OVERRIDE = writeText "lake-manifest-override.json" (
    builtins.toJSON [
      {
        name = "Cli";
        dir = "${Cli}/lib/lean-packages/Cli";
      }
    ]
  );
  nativeBuildInputs = [
    lean4
    lakeSetupHook
  ];
})
