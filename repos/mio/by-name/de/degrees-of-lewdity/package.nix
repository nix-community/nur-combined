{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  tweego,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  electron,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "degrees-of-lewdity";
  version = "0.5.11.9";

  src = fetchFromGitLab {
    domain = "gitgud.io";
    owner = "Vrelnir";
    repo = "degrees-of-lewdity";
    tag = finalAttrs.version;
    hash = "sha256-omN8QYoSiNSLUn3VSdyiY+3jeq9EBdfGHhU+Mz7KL8s=";
  };

  nativeBuildInputs = [
    tweego
    makeWrapper
    copyDesktopItems
  ];

  dontConfigure = true;

  env.TWEEGO_PATH = "devTools/tweego/storyFormats";

  buildPhase = ''
    runHook preBuild

    tweego -o index.html --head devTools/head.html --module modules game/

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -d "$out/share/degrees-of-lewdity"
    cp -a index.html img "$out/share/degrees-of-lewdity/"
    install -Dm644 ${./electron-main.js} "$out/share/degrees-of-lewdity/main.js"
    cat > "$out/share/degrees-of-lewdity/package.json" <<EOF
    {
      "name": "degrees-of-lewdity",
      "main": "main.js"
    }
    EOF

    install -Dm644 devTools/apkbuilder/res/icon-xxxhdpi.png \
      "$out/share/icons/hicolor/192x192/apps/degrees-of-lewdity.png"

    makeWrapper ${lib.getExe electron} "$out/bin/degrees-of-lewdity" \
      --add-flags "$out/share/degrees-of-lewdity" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "degrees-of-lewdity";
      exec = "degrees-of-lewdity %U";
      icon = "degrees-of-lewdity";
      desktopName = "Degrees of Lewdity";
      comment = finalAttrs.meta.description;
      categories = [ "Game" ];
    })
  ];

  meta = {
    description = "Single-player adult school-life RPG written in Twine/SugarCube";
    homepage = "https://gitgud.io/Vrelnir/degrees-of-lewdity";
    license = lib.licenses.cc-by-nc-sa-40;
    mainProgram = "degrees-of-lewdity";
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
