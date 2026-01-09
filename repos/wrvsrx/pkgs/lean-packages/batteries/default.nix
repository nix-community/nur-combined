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
  nativeBuildInputs = [
    lean4
    lakeSetupHook
  ];
})
