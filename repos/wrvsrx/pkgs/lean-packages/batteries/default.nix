{
  stdenv,
  fetchFromGitHub,
  lean4,
  lakeSetupHook,
  writeText,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "batteries";
  version = "4.25.0";
  src = fetchFromGitHub {
    owner = "leanprover-community";
    repo = "batteries";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RiawFpdXcaLtw+LjPOervw4Xr7a/xJdqT6xPmbg45hE=";
  };
  env.NIX_LAKE_MANIFEST_OVERRIDE = writeText "lake-manifest-overrided.json" (builtins.toJSON [ ]);
  nativeBuildInputs = [
    lean4
    lakeSetupHook
  ];
})
