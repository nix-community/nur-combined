# to start it, run the above
# change PAPRA_PACKAGE_PATH
# check site on http://localhost:1221/
/*
nix shell nixpkgs#nodejs nixpkgs#tsx
export PAPRA_PACKAGE_PATH=result
export DATABASE_URL=file:$HOME/.cache/papra-demo/db.sqlite
tsx $PAPRA_PACKAGE_PATH/apps/papra-server/src/scripts/migrate-up.script.ts
pushd $PAPRA_PACKAGE_PATH/apps/papra-server/dist; SERVER_SERVE_PUBLIC_DIR=true NODE_ENV=production DOCUMENT_STORAGE_FILESYSTEM_ROOT=$HOME/.cache/papra-demo/document-storage PAPRA_CONFIG_DIR=$HOME/.cache/papra-demo/config EMAILS_DRY_RUN=true CLIENT_BASE_URL=http://localhost:1221 node index.js; popd
*/

pkgs:
with pkgs;

stdenv.mkDerivation (finalAttrs: {
  pname = "papra";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "papra-hq";
    repo = "papra";
    rev = "a62d3767729ab02ae203a1ac7b7fd6eb6e011d98";
    hash = "sha256-yK3KRHE/L755AetOQSISHkroowz4Mv/c6UtbPXi4sXc=";
  };

  nativeBuildInputs = [
    pnpm_10.configHook
    nodejs
    node-gyp
    python3
    vips
    vips.out
    vips.dev
    glib
    glib.dev
    pkg-config
    gobject-introspection
    gtk4
  ];

  pnpmDeps = pnpm_10.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-4EzN9gdCAplUEr/YNUaTPgDeNghKBQVgy2Vvs8Rh2z0=";
    fetcherVersion = 2;
  };

  buildPhase = ''
    pushd node_modules/.pnpm/sharp@0.32.6/node_modules/sharp
    node-gyp rebuild
    popd

    pnpm run build:packages

    pushd apps/papra-client
    pnpm run build
    popd

    pushd apps/papra-server
    pnpm run build
    popd
  '';

  installPhase = ''
    cp -r . $out

    cp -r apps/papra-client/dist $out/apps/papra-server/dist/public
  '';

  dontFixup = true;
})
