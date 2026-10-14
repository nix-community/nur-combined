# The npm tarball is upstream's release build: one bun bundle beside its reference bank, with only ink, react and terminal-link left external.
# Upstream publishes no lockfile, so update-lockfiles resolves the one beside this file.
{
  lib,
  buildNpmPackage,
  nodejs_24,
  source,
}:
buildNpmPackage {
  inherit (source) pname version src;

  nodejs = nodejs_24;

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  # Refreshed by update-hashes.
  npmDepsHash = "sha256-BQlXQ3N219PgEJl8d3o+eBDOb8o72UE849hlBbXPbzc=";

  dontNpmBuild = true;

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    # Help renders through ink, so this also proves the three external packages resolve.
    $out/bin/fpd --help | grep -qF -- '--baseurl'

    runHook postInstallCheck
  '';

  meta = {
    description = "Model fingerprint detection: identify the LLM behind an API from a few hundred integers it writes";
    homepage = "https://github.com/Ikaleio/lm-detector";
    license = lib.licenses.mit;
    mainProgram = "fpd";
    maintainers = [
      {
        name = "mzwing";
      }
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
