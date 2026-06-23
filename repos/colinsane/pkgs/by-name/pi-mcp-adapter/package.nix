{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-mcp-adapter";
  version = "2.10.0";

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-mcp-adapter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-I3FIvHlGCNUZhZlr3sOOSE7SJ78XTQyAvlzGk84Klf0=";
    # upstream omits the integrity hashes for pi-* dependencies, expecting pi to already be present.
    # patch out the deps onto pi *here*, so that nix-update-script can generate a correct lockfile.
    postFetch = ''
      sed -i $out/package.json \
        -e '/"@earendil-works\/pi-ai": /d' \
        -e '/"@earendil-works\/pi-tui": /d' \
        -e '/"@earendil-works\/pi-coding-agent": /d'
    '';
  };

  npmDepsFetcherVersion = 2;

  npmDepsHash = "sha256-ANtji4r1e2bcV5nfxttnpVKHSy6q0c0cHwt5VfJPICY=";

  # lockfile generated in a pi-mcp-adapter checkout using
  # `npm install --package-lock-only`.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  # this is a pi extension consisting of TypeScript sources loaded at runtime;
  # there is nothing to compile.
  dontNpmBuild = true;

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
    description = "MCP (Model Context Protocol) adapter extension for the Pi coding agent";
    homepage = "https://github.com/nicobailon/pi-mcp-adapter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
