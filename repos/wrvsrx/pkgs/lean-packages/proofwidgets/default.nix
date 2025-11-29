{
  stdenv,
  fetchFromGitHub,
  lean4,
  lakeSetupHook,
  nodejs,
  fetchNpmDeps,
  replaceVars,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "proofwidgets";
  version = "0.0.79";
  src = fetchFromGitHub {
    owner = "leanprover-community";
    repo = "ProofWidgets4";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4Ka7d98xdbDoX/tyFyygtks0Qpx5ZlXNraGj2Lh5siE=";
  };
  patches = [
    (replaceVars ./npm.patch { inherit nodejs; })
  ];
  passthru.npmDeps = fetchNpmDeps {
    name = "widget";
    hash = "sha256-CzBRrreOSytquZ/xFHPlY8r+lz5Bg9Zk9ienRhc8SiY=";
    inherit (finalAttrs) src;
    sourceRoot = "${finalAttrs.src.name}/widget";
  };
  preBuild = ''
    export npm_config_cache="${finalAttrs.passthru.npmDeps}"
    export npm_config_offline="true"
    export npm_config_progress="false"
  '';
  nativeBuildInputs = [
    lean4
    lakeSetupHook
    nodejs
  ];
})
