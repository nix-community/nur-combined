{
  lib,
  stdenvNoCC,
  callPackage,
  bun,
  makeWrapper,
  nodejs_24,
  source,
}: let
  version = lib.removePrefix "v" source.version;

  # Refreshed by update-hashes via passthru.updateCustomDeps.
  bunDepsHash = "sha256-CVjNWWkFk0WGToNVEqOXcxy6qH2HmiAyIxDd56exz0U=";

  nodeModules = callPackage ./deps.nix {inherit source version bunDepsHash;};

  pkgDir = "$out/lib/node_modules/@cortexkit/magic-context";
in
  stdenvNoCC.mkDerivation {
    inherit (source) pname src;
    inherit version;

    nativeBuildInputs = [bun makeWrapper];

    postPatch = ''
      cp -R ${nodeModules}/. .
      find . -maxdepth 3 -type d -name node_modules -prune -exec chmod -R u+w {} +
    '';

    buildPhase = ''
      runHook preBuild

      # The cwd matters: the @magic-context/core alias lives in this package's tsconfig paths.
      cd packages/cli
      bun build src/index.ts \
        --outfile dist/index.js \
        --target node \
        --format esm \
        --external node:sqlite
      cd ../..

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      # --version reads ../package.json relative to dist/index.js.
      install -Dm644 packages/cli/package.json ${pkgDir}/package.json
      install -Dm644 packages/cli/dist/index.js ${pkgDir}/dist/index.js

      # No PATH injection: setup and doctor shell out to the user's own harness.
      makeWrapper ${lib.getExe nodejs_24} $out/bin/magic-context \
        --add-flags ${pkgDir}/dist/index.js

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      $out/bin/magic-context --version | grep -Fx '${version}'
      $out/bin/magic-context --help >/dev/null

      runHook postInstallCheck
    '';

    passthru = {
      inherit nodeModules;

      # nix-update only knows its own hash attributes; update-hashes turns this into --custom-dep.
      updateCustomDeps = ["nodeModules"];
    };

    meta = {
      description = "Unbounded context. Memory that manages itself. One session, for life. The hippocampus for coding agents, part of CortexKit";
      homepage = "https://github.com/cortexkit/magic-context";
      changelog = "https://github.com/cortexkit/magic-context/releases/tag/${source.version}";
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
