# The npm package is upstream's release build: one bun bundle beside its reference bank, with only ink, react and terminal-link left external.
{
  lib,
  buildNpmPackage,
  makeWrapper,
  nodejs_24,
  source,
}:
buildNpmPackage {
  pname = "lmfpd";
  inherit (source) version npmDepsHash;

  # source.ts generates a private manifest depending on the published package, and its lock.
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./package.json
      ./package-lock.json
    ];
  };

  nodejs = nodejs_24;

  nativeBuildInputs = [makeWrapper];

  dontNpmBuild = true;

  # Packing the private manifest would ship nothing, so install the resolved tree itself.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp -r node_modules $out/lib/node_modules
    makeWrapper ${lib.getExe nodejs_24} $out/bin/fpd \
      --add-flags $out/lib/node_modules/lmfpd/bin/fpd.js

    runHook postInstall
  '';

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
