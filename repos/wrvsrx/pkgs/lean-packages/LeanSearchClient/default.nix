{
  stdenv,
  lean4,
  lakeSetupHook,
  source,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (source) pname src;
  version = "4.12.0-unstable-2026-01-29"; # Keep the original version format since it's commit-based
  nativeBuildInputs = [
    lean4
    lakeSetupHook
  ];
})
