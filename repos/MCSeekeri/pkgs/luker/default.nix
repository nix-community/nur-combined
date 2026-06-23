{
  lib,
  buildNpmPackage,
  nix-update-script,
  fetchFromGitHub,
  git,
  makeWrapper,
  nodejs_26,
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

  nodejs = nodejs_26;
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
    mkdir -p "$out/lib/node_modules/luker/backups"
    mkdir -p "$out/lib/node_modules/luker/public/scripts/extensions/third-party"

    # Support services.sillytavern.package = pkgs.luker
    ln -s luker "$out/lib/node_modules/sillytavern"

    wrapProgram "$out/bin/luker" \
      --set NODE_ENV production \
      --set LUKER_UPDATE_REMOTE "" \
      --prefix PATH : ${lib.makeBinPath [ git ]} \
      --run 'data_dir="''${XDG_DATA_HOME:-$HOME/.local/share}/SillyTavern"; mkdir -p "$data_dir/plugins" "$data_dir/public/scripts/extensions/third-party"' \
      --add-flags '--serverPluginsPath "''${XDG_DATA_HOME:-$HOME/.local/share}/SillyTavern/plugins"' \
      --add-flags '--globalExtensionsPath "''${XDG_DATA_HOME:-$HOME/.local/share}/SillyTavern/public/scripts/extensions/third-party"'
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "SillyTavern fork focused on customizable AI chat interfaces";
    longDescription = ''
      Luker is a feature-rich fork of SillyTavern with multi-agent orchestration,
      iteration studio, memory graph, and deep AI character interaction controls.
    '';
    homepage = "https://github.com/funnycups/Luker";
    changelog = "https://github.com/funnycups/Luker/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "luker";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
