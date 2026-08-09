{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
  nodejs_26,
}:

buildNpmPackage (finalAttrs: {
  pname = "github-readme-stats";
  version = "1.1.6-unstable-2026-05-19";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "bartoostveen";
    repo = "github-readme-stats";
    rev = "4072cfc0bb99ceed46814b05818138c01c8e8539";
    hash = "sha256-bOzOI3YSIqgQXahoXW65A5VL+29qmQ388VAuOqh3RJk=";
  };

  npmDepsHash = "sha256-oiB+OA6a/okbWezOODY8EpWPxy6BgnceoXQrOOIZUy4=";

  dontNpmBuild = true;

  installPhase = ''
    runHook preInstall
    cp -r . $out/
    makeWrapper ${lib.getExe nodejs_26} $out/bin/${finalAttrs.pname} --append-flag "$out/express.js"
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch=master" ]; };

  meta = {
    description = "Zap: Dynamically generated stats for your github readmes";
    homepage = "https://github.com/anuraghazra/github-readme-stats";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = finalAttrs.pname;
    platforms = lib.platforms.all;
    knownVulnerabilities = [
      ''
        github-readme-stats is not maintained anymore/deprecated. See:
        <https://github.com/anuraghazra/github-readme-stats/blob/54a7985aeefda00d5eadb55b80c17c7f976c37d2/readme.md#github-readme-stats>

        Given the state of the NodeJS ecosystem as of writing, packages can become vulnerable pretty quickly.
        Consider installing GitHub Stats Extended, the successor and/or drop-in replacement for this package.
      ''
    ];
  };
})
