{
  stdenv,
  fetchFromGitHub,
  lean4,
  lakeSetupHook,
  writeText,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xdg";
  version = "0.2.0";
  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "xdg";
    tag = finalAttrs.version;
    hash = "sha256-HKD3zchrhuqHM6fjmFQMardb9ov3GG7rki2kjW8oLas=";
  };
  env.NIX_LAKE_MANIFEST_OVERRIDE = writeText "lake-manifest-overrided.json" (builtins.toJSON [ ]);
  nativeBuildInputs = [
    lean4
    lakeSetupHook
  ];
})
