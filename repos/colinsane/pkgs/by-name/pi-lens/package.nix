{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-lens";
  version = "3.8.61";

  src = fetchFromGitHub {
    owner = "apmantza";
    repo = "pi-lens";
    tag = "v${finalAttrs.version}";
    hash = "sha256-++BOHPAR4oOP7BhpF2IlRdpE03p0YvZ6RyBl2wAVX+Y=";
    postFetch = ''
      substituteInPlace $out/package.json \
        --replace-fail '"tree-sitter-wasms": "npm:null@^0.11.0",'  "" \
        --replace-fail '"web-tree-sitter": "0.25.10"'  ""
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

  installPhase = ''
    runHook preInstall
    cp -R . $out
    runHook postInstall
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
