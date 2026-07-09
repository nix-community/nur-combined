{ lib, stdenvNoCC, fetchFromGitHub, fetchpatch, useNixPatch ? true, gitUpdater, maintainers }: stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "agent-safehouse";
    version = "0.11.0";
    src = fetchFromGitHub {
        owner = "eugene1g";
        repo = "agent-safehouse";
        tag = "v${finalAttrs.version}";
        deepClone = true;
        postFetch = ''
            shopt -s globstar
            pushd "$out"
            git log -1 --format=%ct -- profiles/**/*.sb > .profiles_last_modified_epoch
            rm -rf .git
            popd
            shopt -u globstar
        '';
        hash = "sha256-WF2l/ScCjcKmOBckS8SQrWIW4oogmsGFBxYBBX9k7uY=";
    };
    postPatch = ''
        substituteInPlace scripts/generate-dist.sh --replace-fail \
            '$(git -C "$ROOT_DIR" log -1 --format=%ct -- "''${profile_files[@]}" 2>/dev/null || true)' \
            '$(<"$ROOT_DIR/.profiles_last_modified_epoch")'
    '';
    buildPhase = ''
        runHook preBuild
        scripts/generate-dist.sh
        runHook postBuild
    '';
    installPhase = ''
        runHook preInstall
        install -Dm755 dist/safehouse.sh "$out"/bin/safehouse
        runHook postInstall
    '';
    patches = lib.optional useNixPatch (fetchpatch {
        name = "support-nix-package-manager.patch";
        urls = [
            "file://${./support-nix-package-manager.patch}"
            "https://github.com/Rhys-T/agent-safehouse/commit/cd0f83db603f1e6036ec781ccdba2ed8d16213f4.patch"
        ];
        hash = "sha256-I0DbATAcMbYBE77nPDemrpPOMjZ4lPvoqdkBjuykgJo=";
    });
    meta = {
        description = "macOS sandbox wrapper for coding agents";
        homepage = "https://agent-safehouse.dev/";
        license = lib.licenses.asl20;
        mainProgram = "safehouse";
        platforms = lib.platforms.darwin;
        maintainers = [maintainers.Rhys-T];
    };
    passthru.updateScript = gitUpdater {
        rev-prefix = "v";
    };
})
