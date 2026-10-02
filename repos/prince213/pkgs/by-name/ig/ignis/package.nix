{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchurl,
  stdenvNoCC,

  # nativeBuildInputs
  asar,
  gzip,
  makeBinaryWrapper,

  # buildInputs
  nodejs-slim_22,
}:

buildNpmPackage (finalAttrs: {
  pname = "ignis";
  version = "0.8.15";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Nystik-gh";
    repo = "ignis";
    tag = "v${finalAttrs.version}+obsidian.${finalAttrs.passthru.obsidianAssets.version}";
    hash = "sha256-8HVEaBhqp3Xb4r0CTLZGdKM02Ejqc4F7+qHvvqyjB8Y=";
  };

  npmDepsHash = "sha256-spaCD2VS3aNMAQVPnR1xD8IpX1KG2orjtS2B2ij1Up8=";

  nativeBuildInputs = [ makeBinaryWrapper ];

  env.IGNIS_BUILD = "0000000";

  postInstall = ''
    mv $out/lib/node_modules/ignis-monorepo $out/lib/ignis
    rm -r $out/lib/node_modules

    for i in packages/shim/dist \
             packages/ui/dist \
             apps/ignis-server/server/build-info.json \
             apps/ignis-server/server/plugins/headless-sync/obsidian/dist; do
      cp -r $i $out/lib/ignis/$i
    done

    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs-slim_22} $out/bin/ignis \
      --set-default VAULT_ROOT ./vaults \
      --set-default DATA_ROOT ./data \
      --set-default OBSIDIAN_ASSETS_PATH ${finalAttrs.passthru.obsidianAssets} \
      --add-flags $out/lib/ignis/apps/ignis-server/server/index.js
  '';

  passthru = {
    obsidianAssets = stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "obsidian-assets";
      version = "1.13.7";

      src = fetchurl {
        url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v${finalAttrs.version}/obsidian-${finalAttrs.version}.asar.gz";
        hash = "sha256-aSU+OaoLmA48+W6eiopL7Wtkge9wIc12L2eHJmLY0lo=";
      };

      nativeBuildInputs = [
        asar
        gzip
      ];

      unpackPhase = ''
        runHook preUnpack
        gzip -dc $src > app.asar
        asar extract app.asar app
        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall
        cp -r app $out
        runHook postInstall
      '';

      meta.license = lib.licenses.obsidian;
    });
  };

  meta = {
    description = "Browser-based Obsidian client";
    homepage = "https://ignis.thiefling.com/docs/";
    downloadPage = "https://github.com/Nystik-gh/ignis/releases";
    changelog = "https://github.com/Nystik-gh/ignis/blob/HEAD/CHANGELOG.md";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "ignis";
  };
})
