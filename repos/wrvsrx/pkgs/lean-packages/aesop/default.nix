{
  stdenv,
  fetchFromGitHub,
  lean4,
  lakeSetupHook,
  writeText,
  batteries,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "aesop";
  version = "4.24.0";
  src = fetchFromGitHub {
    owner = "leanprover-community";
    repo = "aesop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TBOojdkPY045srjdvOp5PEgDswku0ESsjJ006it75f4=";
  };
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
