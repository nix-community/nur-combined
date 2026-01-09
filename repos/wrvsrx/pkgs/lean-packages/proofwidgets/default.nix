{
  stdenv,
  lean4,
  lakeSetupHook,
  nodejs,
  fetchNpmDeps,
  replaceVars,
  lib,
  source,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;
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
