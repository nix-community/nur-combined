{
  stdenv,
  lean4,
  lakeSetupHook,
  lib,
  source,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;
  env.NIX_LAKE_TARGETS = "Cli:shared";
  nativeBuildInputs = [
    lean4
    lakeSetupHook
  ];
})
