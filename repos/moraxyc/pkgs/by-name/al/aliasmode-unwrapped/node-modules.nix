{
  lib,
  stdenvNoCC,
  bun,
  sources,
  source ? sources.aliasmode,
}:
stdenvNoCC.mkDerivation {
  pname = "aliasmode-node-modules";
  inherit (source) version src;
  nativeBuildInputs = [ bun ];
  patches = [ source.artifacts."fix-playwright-patch.patch" ];
  dontConfigure = true;
  dontFixup = true;
  buildPhase = ''
    runHook preBuild
    export HOME="$TMPDIR"
    export BUN_INSTALL_CACHE_DIR="$TMPDIR/bun-cache"
    bun install --frozen-lockfile --ignore-scripts --no-progress
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mv node_modules "$out"
    runHook postInstall
  '';
  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  outputHash = source.nodeModulesHash;
}
