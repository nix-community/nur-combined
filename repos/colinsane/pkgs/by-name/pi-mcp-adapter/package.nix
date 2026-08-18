{
  buildNpmPackage,
  fetchFromGitHub,
  jq,
  lib,
  moreutils,
  nix-update-script,
  update-guard,
  updater-tools,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-mcp-adapter";
  version = "2.26.0";

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-mcp-adapter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cz7sh6Zp1DUsydiVDImoTuO4cuU+27NcUWYUxQOIgE0=";
    # upstream omits the integrity hashes for pi-* dependencies, expecting pi to already be present.
    # patch out the deps onto pi *here*, so that nix-update-script can generate a correct lockfile.
    postFetch = ''
      jq '
        del(
          .dependencies["@earendil-works/pi-ai", "@earendil-works/pi-tui", "@earendil-works/pi-coding-agent"],
          .devDependencies["@earendil-works/pi-ai", "@earendil-works/pi-tui", "@earendil-works/pi-coding-agent"],
          .peerDependencies["@earendil-works/pi-ai", "@earendil-works/pi-tui", "@earendil-works/pi-coding-agent"],
          .peerDependenciesMeta["@earendil-works/pi-ai", "@earendil-works/pi-tui", "@earendil-works/pi-coding-agent"]
        )
      ' $out/package.json | sponge $out/package.json
    '';
    nativeBuildInputs = [
      jq
      moreutils
    ];
  };

  npmDepsFetcherVersion = 2;

  npmDepsHash = "sha256-iSYoCzuel5bnEYTNVaF8HnNtIRtZvYzTJNUAXmIskJo=";

  # lockfile generated in a pi-mcp-adapter checkout using
  # `npm install --package-lock-only`.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  postInstall = ''
    mv $out/lib/node_modules/pi-mcp-adapter/* $out
    rmdir $out/lib/node_modules/pi-mcp-adapter
    rmdir $out/lib/node_modules
    rmdir $out/lib
  '';

  passthru.updateScript = updater-tools.requireAll [
    (update-guard.days 3)
    (nix-update-script {
      extraArgs = [
        "--generate-lockfile"
      ];
    })
  ];

  meta = {
    description = "MCP (Model Context Protocol) adapter extension for the Pi coding agent";
    homepage = "https://github.com/nicobailon/pi-mcp-adapter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
