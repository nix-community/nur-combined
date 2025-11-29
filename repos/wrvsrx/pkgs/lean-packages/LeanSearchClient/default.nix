{
  stdenv,
  fetchFromGitHub,
  lean4,
  lakeSetupHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "LeanSearchClient";
  version = "4.12.0-unstable-2025-11-29";
  src = fetchFromGitHub {
    owner = "leanprover-community";
    repo = "LeanSearchClient";
    rev = "3591c3f664ac3719c4c86e4483e21e228707bfa2";
    hash = "sha256-aDYHfikl60O+y3zLvFId8Sr/PypPmCrwxwmzwYnrJTw=";
  };
  nativeBuildInputs = [
    lean4
    lakeSetupHook
  ];
})
