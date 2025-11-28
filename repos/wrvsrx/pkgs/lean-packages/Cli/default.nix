{
  stdenv,
  fetchFromGitHub,
  lean4,
  lakeSetupHook,
  writeText,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "Cli";
  version = "4.22.0+patch1";
  src = fetchFromGitHub {
    owner = "leanprover";
    repo = "lean4-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-c3suMnFEEfgI6b67euP1IRWMT1UgI/0C2J3NzIQmv80=";
  };
  env.NIX_LAKE_MANIFEST_OVERRIDE = writeText "lake-manifest-override.json" (builtins.toJSON [ ]);
  nativeBuildInputs = [
    lean4
    lakeSetupHook
  ];
})
