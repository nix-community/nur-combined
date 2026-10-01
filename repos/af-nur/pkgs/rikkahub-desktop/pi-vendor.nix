# RikkaHub's pc-server half imports upstream pi's TypeScript sources through
# ../../pi/..., but RikkaHub itself ships no pi/: upstream keeps it as a
# gitignored local clone pinned by the Dockerfile (no .gitmodules anywhere in
# the repository), which nothing else can reproduce. Vendored here instead:
#
#   * the pi commit nvfetcher.toml pins (the Dockerfile's `git checkout`),
#   * every patch the release ships in pi-patches/ (the Dockerfile's
#     `git apply ../pi-patches/*.patch`),
#   * the pi-model-data/ model catalogue in packages/ai/src/providers/data/
#     (the Dockerfile's pi-model-data copy; pi's generate-models output is not
#     reproducible from models.dev at build time),
#   * pi's own dependencies, installed from its package-lock.json npm
#     workspace, so bun resolves both pi's relative imports and its
#     @earendil-works/* workspace packages while bundling pc-server.
{
    lib,
    buildNpmPackage,
    sources,
    # Kept as a parameter so scripts/update.py can name a fake hash while
    # building the cache, and read the real one back out of the mismatch.
    npmDepsHash ? "sha256-au70hBfSpB97fZ9KnYre/Oollix8ccHOEIFKMyb2O4Q=",
}:
let
    src = sources.pi.src;
    # nvfetcher.toml pins a commit, so the version is a sha.
    version = sources.pi.version;

    # Patch set as the Dockerfile applies it: every *.patch shipped with the
    # release, in name order.
    patchDir = "${sources.rikkahub-desktop.src}/pi-patches";
    patches = map (name: "${patchDir}/${name}") (
        lib.sort (a: b: a < b) (
            builtins.filter (name: lib.hasSuffix ".patch" name) (
                builtins.attrNames (builtins.readDir patchDir)
            )
        )
    );
in
buildNpmPackage {
    pname = "rikkahub-pi";
    inherit src version patches npmDepsHash;

    # pi is an npm workspace monorepo: fetcher version 2 caches the packuments
    # npm needs to install the workspaces without network access.
    npmDepsFetcherVersion = 2;

    # pc-server bundles the sources itself; there is nothing to build here.
    dontNpmBuild = true;
    # The hook's `npm rebuild` step compiles native addons (canvas wants
    # pkg-config/pixman and friends). Nothing in the pc-server bundle links
    # one - bun only follows the JS - so install scripts stay skipped, as they
    # are for RikkaHub's own bun install.
    npmRebuildFlags = [ "--ignore-scripts" ];
    # The tree is read from the store, never executed or patched: keep it as
    # npm laid it out, native binaries and all.
    dontFixup = true;

    postPatch = ''
        mkdir -p packages/ai/src/providers/data
        cp ${sources.rikkahub-desktop.src}/pi-model-data/*.json \
            ${sources.rikkahub-desktop.src}/pi-model-data/.manifest.json \
            packages/ai/src/providers/data/
    '';

    installPhase = ''
        runHook preInstall
        mkdir -p $out
        cp -a . $out/
        runHook postInstall
    '';
}
