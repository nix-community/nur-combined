{
  stdenv,
  fetchFromGitHub,
  lean4,
  lakeSetupHook,
  writeText,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "batteries";
  version = "4.24.0";
  src = fetchFromGitHub {
    owner = "leanprover-community";
    repo = "batteries";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iO0z7Us5pDSfw61tijLcAnNaq48kh7gOjydZVY57Oxo=";
  };
  env.NIX_LAKE_MANIFEST_OVERRIDE = writeText "lake-manifest-overrided.json" (builtins.toJSON [ ]);
  nativeBuildInputs = [
    lean4
    lakeSetupHook
  ];
})
