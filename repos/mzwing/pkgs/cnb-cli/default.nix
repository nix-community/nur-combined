# The npm tarball is upstream's release build: one bun bundle that requires nothing beyond node built-ins.
{
  lib,
  stdenvNoCC,
  nodejs_24,
  source,
}:
stdenvNoCC.mkDerivation {
  inherit (source) pname version src;

  buildInputs = [nodejs_24];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # No PATH injection: repo detection and login shell out to the user's own git and browser opener.
    install -Dm755 dist/index.js $out/bin/cnb

    install -Dm644 LICENSE.md README.md -t $out/share/doc/cnb-cli

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/cnb --version | grep -Fx '${source.version}'

    runHook postInstallCheck
  '';

  meta = {
    description = "CNB OpenAPI command line tool for issues, pull requests, Git, organizations and every other platform API";
    homepage = "https://cnb.cool/cnb/skills/cnb-skill";
    changelog = "https://cnb.cool/cnb/skills/cnb-skill/-/releases/tag/${source.version}";
    license = lib.licenses.mit;
    mainProgram = "cnb";
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
