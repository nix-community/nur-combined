{
  stdenv,
  fetchFromGitHub,
  lean4,
  lakeSetupHook,
  writeText,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "batteries";
  version = "4.25.1";
  src = fetchFromGitHub {
    owner = "leanprover-community";
    repo = "batteries";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DI302mb2jQgt/Cxo4OiCDrrjPL1vgwijgpePvdWPQvU=";
  };
  env.NIX_LAKE_MANIFEST_OVERRIDE = writeText "lake-manifest-overrided.json" (builtins.toJSON [ ]);
  nativeBuildInputs = [
    lean4
    lakeSetupHook
  ];
})
