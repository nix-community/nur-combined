{
  stdenv,
  fetchFromGitHub,
  lean4,
  lakeSetupHook,
  bubblewrap,
  writeText,
  aesop,
  batteries,
  importGraph,
  proofwidgets,
  plausible,
  LeanSearchClient,
  Qq,
  Cli,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mathlib";
  version = "4.25.0";
  src = fetchFromGitHub {
    owner = "leanprover-community";
    repo = "mathlib4";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eRKlJjd8Hn/kuYbigxrMdCxBHZfNEk1UN61+13N66Qg=";
  };
  env.NIX_LAKE_MANIFEST_OVERRIDE = writeText "lake-manifest-override.json" (
    builtins.toJSON [
      {
        name = "batteries";
        dir = "${batteries}/lib/lean-packages/batteries";
      }
      {
        name = "Qq";
        dir = "${Qq}/lib/lean-packages/Qq";
      }
      {
        name = "aesop";
        dir = "${aesop}/lib/lean-packages/aesop";
      }
      {
        name = "proofwidgets";
        dir = "${proofwidgets}/lib/lean-packages/proofwidgets";
      }
      {
        name = "importGraph";
        dir = "${importGraph}/lib/lean-packages/importGraph";
      }
      {
        name = "LeanSearchClient";
        dir = "${LeanSearchClient}/lib/lean-packages/LeanSearchClient";
      }
      {
        name = "plausible";
        dir = "${plausible}/lib/lean-packages/plausible";
      }
      {
        name = "Cli";
        dir = "${Cli}/lib/lean-packages/Cli";
      }
    ]
  );
  nativeBuildInputs = [
    lean4
    lakeSetupHook
    bubblewrap
  ];
  buildPhase = ''
    bwrap \
      --dev-bind / / \
      --tmpfs ${proofwidgets}/lib/lean-packages/proofwidgets/.lake/config \
      lake build --packages=lake-manifest-overrided.json
  '';
})
