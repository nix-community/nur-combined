{
  stdenv,
  lean4,
  lakeSetupHook,
  writeText,
  batteries,
  lib,
  source,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;
  env.NIX_LAKE_MANIFEST_OVERRIDE = writeText "lake-manifest-override.json" (
    builtins.toJSON [
      {
        name = "batteries";
        dir = "${batteries}/lib/lean-packages/batteries";
      }
    ]
  );
  nativeBuildInputs = [
    lean4
    lakeSetupHook
  ];
})
