{
  lib,
  buildGoModule,
  buildNpmPackage,
  esbuild,
  importNpmLock,
  inter,
  makeWrapper,
  nodejs,
  nodejs-slim,
  openssl,
  prisma-engines_6,

  sources,
  source ? sources.ztnet,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;

  npmDeps = importNpmLock source.npmDeps;
  npmConfigHook = importNpmLock.npmConfigHook;
  npmBuildScript = "build:webpack";

  nativeBuildInputs = [
    esbuild
    makeWrapper
    prisma-engines_6
  ];

  postPatch = ''
    substituteInPlace src/pages/_app.tsx \
      --replace-fail 'import { Inter } from "next/font/google";' 'import localFont from "next/font/local";' \
      --replace-fail 'Inter({ subsets: ["latin"] })' 'localFont({ src: "./Inter.ttf" })'
    cp ${inter}/share/fonts/truetype/InterVariable.ttf src/pages/Inter.ttf

    substituteInPlace prisma/schema.prisma \
      --replace-fail '["native", "debian-openssl-3.0.x", "linux-arm64-openssl-3.0.x"]' '["native"]'

    substituteInPlace src/server/api/routers/adminRoute.ts src/pages/api/mkworld/config.ts \
      --replace-fail '"/usr/local/bin/ztmkworld"' '"${lib.getExe finalAttrs.passthru.ztmkworld}"'
    substituteInPlace src/server/api/routers/adminRoute.ts \
      --replace-fail 'process.cwd()' '(process.env.ZTNET_DATA_DIR || "/var/lib/ztnet")' \
      --replace-fail 'systemctl stop zerotier-one' 'systemctl stop zerotierone' \
      --replace-fail 'systemctl start zerotier-one' 'systemctl start zerotierone' \
      --replace-fail 'const host = url.hostname;' 'const host = url.searchParams.get("host") || url.hostname;'
  '';

  env = {
    NEXT_TELEMETRY_DISABLED = "1";
    NEXT_PUBLIC_APP_VERSION = finalAttrs.version;
    SKIP_ENV_VALIDATION = "1";
    PRISMA_SKIP_POSTINSTALL_GENERATE = "1";
  };

  preBuild = ''
    node_modules/.bin/prisma generate
    esbuild prisma/seed.ts --bundle --platform=node --packages=external --outfile=prisma/seed.js
  '';

  installPhase = ''
    runHook preInstall

    npm prune --omit=dev --ignore-scripts
    mkdir -p $out/share/ztnet
    cp -r .next/standalone/. $out/share/ztnet/
    cp -r node_modules public prisma $out/share/ztnet/
    cp -r .next/static $out/share/ztnet/.next/static

    # Build-time only: SWC compilers, TypeScript, musl prebuilds, and the
    # bundled query engine (PRISMA_QUERY_ENGINE_LIBRARY points at prisma-engines).
    pushd $out/share/ztnet/node_modules
    rm -rf @next/swc-* @swc/core* typescript .bin/{tsc,tsserver} @img/*musl* @parcel/watcher-*musl \
      .prisma/client/libquery_engine.node
    find . -name '*.map' -delete
    # npmConfigHook patched shebangs to the full nodejs (with npm/corepack).
    grep -rlZ ${nodejs} . | xargs -0 sed -i 's|${nodejs}|${nodejs-slim}|g'
    popd

    makeWrapper ${lib.getExe nodejs-slim} $out/bin/ztnet \
      --add-flags "$out/share/ztnet/server.js" \
      --set NODE_ENV production \
      --prefix PATH : ${lib.makeBinPath [ openssl ]} \
      --set NEXT_TELEMETRY_DISABLED 1 \
      --set PRISMA_QUERY_ENGINE_LIBRARY ${prisma-engines_6}/lib/libquery_engine.node

    makeWrapper ${lib.getExe nodejs-slim} $out/bin/ztnet-migrate \
      --add-flags "$out/share/ztnet/node_modules/prisma/build/index.js migrate deploy --schema $out/share/ztnet/prisma/schema.prisma" \
      --prefix PATH : ${lib.makeBinPath [ openssl ]} \
      --set PRISMA_SCHEMA_ENGINE_BINARY ${prisma-engines_6}/bin/schema-engine \
      --set PRISMA_QUERY_ENGINE_LIBRARY ${prisma-engines_6}/lib/libquery_engine.node

    makeWrapper ${lib.getExe nodejs-slim} $out/bin/ztnet-seed \
      --add-flags "$out/share/ztnet/prisma/seed.js" \
      --prefix PATH : ${lib.makeBinPath [ openssl ]} \
      --set PRISMA_QUERY_ENGINE_LIBRARY ${prisma-engines_6}/lib/libquery_engine.node

    runHook postInstall
  '';

  passthru = {
    ztmkworld = buildGoModule {
      pname = "ztmkworld";
      inherit (finalAttrs) version src;

      modRoot = "ztnodeid";
      vendorHash = source.ztmkworldVendorHash;

      subPackages = [ "cmd/mkworld" ];
      ldflags = [ "-s" ];

      postInstall = ''
        mv $out/bin/{,zt}mkworld
      '';

      meta = {
        inherit (finalAttrs.meta) license maintainers platforms;
        mainProgram = "ztmkworld";
      };
    };
  };

  meta = {
    description = "Web interface for private ZeroTier controllers with multiuser and organization support";
    homepage = "https://ztnet.network";
    changelog = "https://github.com/sinamics/ztnet/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "ztnet";
  };
})
