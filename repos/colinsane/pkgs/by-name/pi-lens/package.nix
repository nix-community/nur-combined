{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-lens";
  version = "3.8.67";

  src = fetchFromGitHub {
    owner = "apmantza";
    repo = "pi-lens";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ENyt4KVoqLlQlFSwd55QnzGR1DiivPIijt2rERS9+Nc=";
    postFetch = ''
      sed -E -i $out/package.json \
        -e '/"tree-sitter-wasms": ".*",?/d' \
        -e '/"web-tree-sitter": ".*",?/d'
    '';
  };

  npmDepsFetcherVersion = 2;

  dontNpmBuild = true;

  npmDepsHash = "sha256-9h/lC8evF8r+xgEbQ62NWrN9qe68sXGcM59inhxCanQ=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  buildPhase = ''
    runHook preBuild
    npm run build:dist
    runHook postBuild
  '';

  postInstall = ''
    mv $out/lib/node_modules/pi-lens/* $out
    rmdir $out/lib/node_modules/pi-lens
    rmdir $out/lib/node_modules
    rmdir $out/lib
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--generate-lockfile"
    ];
  };

  meta = {
    description = "Real-time code feedback for pi — LSP, linters, formatters, structural analysis";
    homepage = "https://github.com/apmantza/pi-lens";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
