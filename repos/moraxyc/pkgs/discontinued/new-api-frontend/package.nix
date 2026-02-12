{
  lib,
  buildNpmPackage,
  callPackage,

  stdenvNoCC,
  writableTmpDirAsHomeHook,
  bun,

  new-api,
}:

buildNpmPackage (finalAttrs: {
  pname = "${new-api.pname}-frontnd";
  inherit (new-api) version src;

  node_modules = stdenvNoCC.mkDerivation {
    inherit (finalAttrs) src version sourceRoot;
    pname = "${finalAttrs.pname}-node_modules";
    impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
      "GIT_PROXY_COMMAND"
      "SOCKS_SERVER"
      "NIX_NPM_REGISTRY"
    ];
    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];
    dontConfigure = true;
    buildPhase = ''
      runHook preBuild

      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
      bunArgs=(
        install
        --no-progress
        --frozen-lockfile
        --no-cache
      )

      if [[ -n "$NIX_NPM_REGISTRY" ]]; then
        bunArgs+=(--registry="$NIX_NPM_REGISTRY")
      fi

      bun "''${bunArgs[@]}"

      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall

      mkdir -p $out/node_modules
      cp -R ./node_modules $out

      runHook postInstall
    '';
    dontFixup = true;
    outputHash =
      finalAttrs.passthru.nodeModulesHashes.${stdenvNoCC.hostPlatform.system}
        or (throw "${finalAttrs.pname}: Platform ${stdenvNoCC.hostPlatform.system} is not packaged yet. Supported platforms: x86_64-linux, aarch64-linux.");
    outputHashMode = "recursive";
  };

  sourceRoot = "${finalAttrs.src.name}/web";

  preConfigure = ''
    cp -R ${finalAttrs.node_modules}/node_modules .

    # Bun takes executables from this folder
    chmod -R u+rw node_modules
    chmod -R u+x node_modules/.bin
    patchShebangs node_modules

    export HOME=$TMPDIR
    export PATH="$PWD/node_modules/.bin:$PATH"
  '';

  npmDeps = null;
  npmConfigHook = "";

  installPhase = ''
    runHook preInstall

    cp -r dist $out

    runHook postInstall
  '';

  passthru = {
    # nix-update auto -s node_modules
    nodeModulesHashes = {
      x86_64-linux = "sha256-Cp8pg+FegNz6INJuEvHzUJ96d0qin3njbMuZUl6Ev3w=";
    };
  };

  inherit (new-api) meta;
})
