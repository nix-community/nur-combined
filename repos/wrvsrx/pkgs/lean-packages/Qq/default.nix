{
  stdenv,
  fetchFromGitHub,
  lean4,
  lakeSetupHook,
  writeText,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "Qq";
  version = "4.25.0";
  src = fetchFromGitHub {
    owner = "leanprover-community";
    repo = "quote4";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mx2+EwL7Sxj3tqEE/D5CFfKUOjvRSRSmzupe4qwY5XY=";
  };
  env.NIX_LAKE_MANIFEST_OVERRIDE = writeText "lake-manifest-override.json" (builtins.toJSON [ ]);
  nativeBuildInputs = [
    lean4
    lakeSetupHook
  ];
})
