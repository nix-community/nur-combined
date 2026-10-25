{
  lib,
  fetchurl,
  appimageTools,
  callPackage,
}:
let
  current = lib.trivial.importJSON ./version.json;
  version = current.version;
in
appimageTools.wrapType2 (finalAttrs: {
  pname = "orca";
  inherit version;

  src = fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v${version}/orca-linux.AppImage";
    hash = current.hash;
  };

  extraInstallCommands = ''
    # Install desktop file
    install -Dm644 ${finalAttrs.contents}/orca-ide.desktop $out/share/applications/orca.desktop
    substituteInPlace $out/share/applications/orca.desktop \
      --replace-fail 'Exec=AppRun %U' 'Exec=orca --no-sandbox %U' \
      --replace-fail 'Icon=orca-ide' 'Icon=orca'

    # Install all icon sizes, renaming orca-ide.png to orca.png
    find ${finalAttrs.contents}/usr/share/icons/hicolor -name "orca-ide.png" | while read src; do
      rel="''${src#${finalAttrs.contents}/usr/share/icons/hicolor/}"
      dir="''${rel%/*}"
      mkdir -p "$out/share/icons/hicolor/$dir"
      cp "$src" "$out/share/icons/hicolor/$dir/orca.png"
    done
  '';

  passthru.updateScript = callPackage ../../utils/update.nix {
    pname = "orca";
    versionFile = "pkgs/orca/version.json";
    fetchMetaCommand = "${(callPackage ../../utils/fetcher.nix { }).githubRelease {
      owner = "stablyai";
      repo = "orca";
    }}";
  };

  meta = {
    description = "The AI Orchestrator for 100x builders - run Codex, ClaudeCode, OpenCode or Pi side-by-side";
    homepage = "https://onorca.dev";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = finalAttrs.pname;
  };
})
