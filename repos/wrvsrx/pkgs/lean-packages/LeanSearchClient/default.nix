{
  stdenv,
  lean4,
  lakeSetupHook,
  source,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (source) pname src;
  version = "4.12.0-unstable-2025-11-24"; # Keep the original version format since it's commit-based
  nativeBuildInputs = [
    lean4
    lakeSetupHook
  ];
})
