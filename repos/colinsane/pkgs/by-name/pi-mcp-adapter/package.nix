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
    hash = "sha256-MrorLzxbn3O81B47Nd0d0xnd0xhXgMdobnXgD0axldE=";
  };

  npmDepsFetcherVersion = 2;

  npmDepsHash = "sha256-5X2TqtdEfJuHdJGwZN9gAFsZwIKzajFEGOKipkuKSFo=";

  # upstream ships no lockfile; provide one we generated ourselves (via
  # `npm install --package-lock-only`), otherwise buildNpmPackage fails with:
  # > non-git dependencies should have associated integrity
  #
  # note: npm omits `integrity` for a few nested @earendil-works/* dev deps in
  # the generated lockfile. those `integrity` fields were filled in by hand
  # (from the npm registry's `dist.integrity`); re-running the updateScript will
  # drop them again and the npm-deps fetch will fail until they're restored.
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
