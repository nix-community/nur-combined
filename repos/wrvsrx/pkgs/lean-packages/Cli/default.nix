{
  stdenv,
  fetchFromGitHub,
  lean4,
  lakeSetupHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "Cli";
  version = "4.25.0";
  src = fetchFromGitHub {
    owner = "leanprover";
    repo = "lean4-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pYDj12ZapvYvfRXGudwEwC6RstDNGgr3lSs3aWAGkW4=";
  };
  env.NIX_LAKE_TARGETS = "+Cli:o +Cli.Basic:o +Cli.Extensions:o";
  nativeBuildInputs = [
    lean4
    lakeSetupHook
  ];
})
