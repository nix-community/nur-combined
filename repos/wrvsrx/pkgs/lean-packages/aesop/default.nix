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
  version = "4.25.0";
  src = fetchFromGitHub {
    owner = "leanprover-community";
    repo = "aesop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sMdd17zbLunwfDUk4FSsJa9SUJCLXbP9H4wN+Wl6JeQ=";
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
