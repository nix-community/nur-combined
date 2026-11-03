# The npm tarball is upstream's release build: one bun bundle that requires nothing beyond node built-ins. A source build needs a node_modules FOD whose hash follows the bun in each consumer's nixpkgs
{
  lib,
  stdenvNoCC,
  nodejs_24,
  source,
}: let
  pkgDir = "$out/lib/node_modules/@cortexkit/magic-context";
in
  stdenvNoCC.mkDerivation {
    pname = "magic-context";
    inherit (source) version src;

    buildInputs = [nodejs_24];

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      # --version reads ../package.json relative to dist/index.js.
      mkdir -p ${pkgDir} $out/bin
      cp -r dist package.json ${pkgDir}/

      # No PATH injection: setup and doctor shell out to the user's own harness.
      ln -s ${pkgDir}/dist/index.js $out/bin/magic-context

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      $out/bin/magic-context --version | grep -Fx '${source.version}'
      $out/bin/magic-context --help >/dev/null

      runHook postInstallCheck
    '';

    meta = {
      description = "Unbounded context. Memory that manages itself. One session, for life. The hippocampus for coding agents, part of CortexKit";
      homepage = "https://github.com/cortexkit/magic-context";
      changelog = "https://github.com/cortexkit/magic-context/releases/tag/v${source.version}";
      license = lib.licenses.mit;
      mainProgram = "magic-context";
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
