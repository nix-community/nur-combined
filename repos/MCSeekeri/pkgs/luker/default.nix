{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  git,
  makeWrapper,
  nodejs_24,
}:

buildNpmPackage (finalAttrs: {
  pname = "luker";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "funnycups";
    repo = "Luker";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6HGhe/qnup/nrhMttYYiMFshGvXuUffYJk8gv3PoHJ8=";
  };

  nodejs = nodejs_24;
  npmDepsHash = "sha256-KcsXA/ziIYM7XVUEvt00H3osTLlh1hmemsanJPtMPDI=";

  npmFlags = [
    "--ignore-scripts"
    "--no-audit"
    "--no-fund"
    "--loglevel=error"
    "--no-progress"
  ];
  npmInstallFlags = [ "--omit=dev" ];

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    rm -f .npmrc
    sed -i 's/LUKER_UPDATE_REMOTE || /LUKER_UPDATE_REMOTE ?? /g' src/util.js
  '';

  buildPhase = ''
    runHook preBuild

    node ./docker/build-lib.js

    runHook postBuild
  '';

  postInstall = ''
    mkdir -p $out/lib/node_modules/luker/backups
    mkdir -p $out/lib/node_modules/luker/public/scripts/extensions/third-party

    wrapProgram "$out/bin/luker" \
      --set NODE_ENV production \
      --set LUKER_UPDATE_REMOTE "" \
      --prefix PATH : ${lib.makeBinPath [ git ]} \
      --run 'data_dir="''${XDG_DATA_HOME:-$HOME/.local/share}/SillyTavern"; mkdir -p "$data_dir/plugins" "$data_dir/public/scripts/extensions/third-party"' \
      --add-flags '--serverPluginsPath "''${XDG_DATA_HOME:-$HOME/.local/share}/SillyTavern/plugins"' \
      --add-flags '--globalExtensionsPath "''${XDG_DATA_HOME:-$HOME/.local/share}/SillyTavern/public/scripts/extensions/third-party"'
  '';

  meta = {
    description = "SillyTavern fork focused on customizable AI chat interfaces";
    homepage = "https://github.com/funnycups/Luker";
    changelog = "https://github.com/funnycups/Luker/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "luker";
    platforms = lib.platforms.linux;
  };
})
