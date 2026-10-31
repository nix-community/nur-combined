# The npm tarball is upstream's compiled ESM tree; it needs nothing beyond node built-ins, node:sqlite included.
{
  lib,
  stdenvNoCC,
  nodejs_24,
  source,
}: let
  pkgDir = "$out/lib/node_modules/@obelisk-apps/cli";
in
  stdenvNoCC.mkDerivation {
    pname = "obelisk";
    inherit (source) version src;

    buildInputs = [nodejs_24];

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      # node reads the module type from package.json, and --version reads it relative to the entry point.
      mkdir -p ${pkgDir} $out/bin
      cp -r dist package.json ${pkgDir}/
      ln -s ${pkgDir}/dist/cli/src/obelisk.js $out/bin/obelisk

      install -Dm644 README.md -t $out/share/doc/obelisk

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      $out/bin/obelisk --version | grep -Fx '${source.version}'

      runHook postInstallCheck
    '';

    meta = {
      description = "Past coding-agent sessions indexed into one SQLite database, queryable by your agent";
      homepage = "https://github.com/tommy0103/obelisk";
      license = lib.licenses.agpl3Only;
      mainProgram = "obelisk";
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
