{
  stdenv,
  fetchFromGitHub,
  lean4,
  lakeSetupHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "plausible";
  version = "4.25.0";
  src = fetchFromGitHub {
    owner = "leanprover-community";
    repo = "plausible";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SLcDytxk2qCHznP/OS1gZQ31B1V4DdwzrDsQYVUFE1E=";
  };
  nativeBuildInputs = [
    lean4
    lakeSetupHook
  ];
})
