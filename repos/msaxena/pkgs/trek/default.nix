{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
}:

buildNpmPackage (finalAttrs: {
  pname = "trek";
  version = "3.4.1";

  src = fetchFromGitHub {
    owner = "liketrek";
    repo = "TREK";
    tag = "v${finalAttrs.version}";
    hash = "sha256-r7Y6vxksX+V4bKCz4MF7K8Ar5UgKIzHoJmjukgR+9Cw=";
  };

  npmDepsHash = "sha256-m+2OFN8EbyCv+sc5T3TcNxjR5tl9qKMzqyLIqrTrews=";

  nativeBuildInputs = [ makeWrapper ];

  # The root "build" script builds the npm workspaces in dependency order:
  # shared -> server -> client (mirrors the upstream Dockerfile stages).
  installPhase = ''
    runHook preInstall

    npm prune --omit=dev --no-save
    find node_modules -maxdepth 1 -type d -empty -delete

    mkdir -p $out/lib/trek
    cp -r node_modules $out/lib/trek/node_modules
    # Only server (and shared, its workspace dependency) are needed at
    # runtime; drop the dangling workspace symlink for the client, whose
    # built assets are copied into server/public below instead.
    rm -f $out/lib/trek/node_modules/@trek/client

    mkdir -p $out/lib/trek/shared
    cp shared/package.json $out/lib/trek/shared/
    cp -r shared/dist $out/lib/trek/shared/dist

    mkdir -p $out/lib/trek/server/scripts
    cp server/package.json server/tsconfig.json server/reset-admin.js $out/lib/trek/server/
    cp server/scripts/migrate-encryption.ts $out/lib/trek/server/scripts/
    cp -r server/dist $out/lib/trek/server/dist
    cp -r server/assets $out/lib/trek/server/assets

    cp -r client/dist $out/lib/trek/server/public
    mkdir -p $out/lib/trek/server/public/fonts
    cp -r client/public/fonts/. $out/lib/trek/server/public/fonts/

    cp -r wiki $out/lib/trek/wiki

    # The server resolves its SQLite database and uploads relative to
    # process.cwd() as "./data" and "./uploads" (matching upstream's Docker
    # image). These are plain empty directories rather than paths baked to
    # some fixed runtime location, so the package stays agnostic of where
    # state actually lives; the NixOS module bind-mounts its (configurable)
    # state directory over these two at service start (see
    # services.trek.dataDir).
    mkdir -p $out/lib/trek/server/data $out/lib/trek/server/uploads

    makeWrapper ${lib.getExe nodejs} $out/bin/trek \
      --add-flags "--require tsconfig-paths/register $out/lib/trek/server/dist/index.js" \
      --chdir "$out/lib/trek/server"

    runHook postInstall
  '';

  meta = {
    description = "Self-hosted, real-time collaborative travel planner with mapping, budgeting, packing lists and journaling";
    longDescription = ''
      TREK is a self-hosted travel planning application. It provides
      interactive trip mapping, collaborative real-time editing, budgeting,
      packing lists, journaling, and OIDC/WebAuthn-backed authentication, all
      backed by a local SQLite database.
    '';
    homepage = "https://github.com/liketrek/TREK";
    changelog = "https://github.com/liketrek/TREK/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "trek";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
