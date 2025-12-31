{
  stdenv,
  fetchFromGitHub,
  lean4,
  lakeSetupHook,
  writeText,
  Cli,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "importGraph";
  version = "4.25.0";
  src = fetchFromGitHub {
    owner = "leanprover-community";
    repo = "import-graph";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1xdvh1QvXbNoUXyfCe7gTmOV+sZzkGeqFrKTaS9wiGw=";
  };
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
