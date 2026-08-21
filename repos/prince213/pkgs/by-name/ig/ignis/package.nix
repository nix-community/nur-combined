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
  version = "0.8.10";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Nystik-gh";
    repo = "ignis";
    tag = "v${finalAttrs.version}+obsidian.${finalAttrs.passthru.obsidianAssets.version}";
    hash = "sha256-gbonsBzXsEo7ZHnqNNx/lmPsrj1DQXi0/JFg/HqIfxg=";
  };

  npmDepsHash = "sha256-HCd/Kc1bpr7HlysQCEGnU7Si3g3QvWuEXfSJ9fEM0Gc=";

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
      version = "1.12.7";

      src = fetchurl {
        url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v${finalAttrs.version}/obsidian-${finalAttrs.version}.asar.gz";
        hash = "sha256-dd008UydtVj7rRnoDwsgG8mAW1G3OINwJ34PkaOL2FA=";
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
