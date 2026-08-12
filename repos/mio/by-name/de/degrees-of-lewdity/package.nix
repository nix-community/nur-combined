{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  tweego,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  writeText,
  electron,
  nix-update-script,
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

  strictDeps = true;

  nativeBuildInputs = [
    tweego
    makeWrapper
    copyDesktopItems
  ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    export TWEEGO_PATH="$PWD/devTools/tweego/storyFormats"
    tweego -o index.html --head devTools/head.html --module modules game/

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 index.html "$out/share/${finalAttrs.pname}/index.html"
    cp -R img "$out/share/${finalAttrs.pname}/img"
    rm -f "$out/share/${finalAttrs.pname}/img/"*.{bat,yml}

    install -Dm644 ${./electron-main.js} "$out/share/${finalAttrs.pname}/main.js"
    install -Dm644 ${
      writeText "package.json" (
        builtins.toJSON {
          name = finalAttrs.pname;
          productName = "Degrees of Lewdity";
          version = finalAttrs.version;
          main = "main.js";
        }
      )
    } "$out/share/${finalAttrs.pname}/package.json"

    for icon in \
      36:icon-ldpi.png \
      48:icon-mdpi.png \
      72:icon-hdpi.png \
      96:icon-xhdpi.png \
      144:icon-xxhdpi.png \
      192:icon-xxxhdpi.png; do
      size=''${icon%%:*}
      file=''${icon##*:}
      install -Dm644 "devTools/apkbuilder/res/$file" \
        "$out/share/icons/hicolor/''${size}x''${size}/apps/${finalAttrs.pname}.png"
    done

    # makeWrapper (shell) is required so NIXOS_OZONE_WL expands at runtime.
    # https://github.com/NixOS/nixpkgs/issues/172583
    makeWrapper '${lib.getExe electron}' "$out/bin/${finalAttrs.pname}" \
      --inherit-argv0 \
      --set ELECTRON_FORCE_IS_PACKAGED 1 \
      --add-flags "$out/share/${finalAttrs.pname}" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      exec = "${finalAttrs.pname} %U";
      icon = finalAttrs.pname;
      desktopName = "Degrees of Lewdity";
      genericName = "Text adventure";
      comment = finalAttrs.meta.description;
      categories = [
        "Game"
        "RolePlaying"
      ];
      startupWMClass = "degrees-of-lewdity";
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Single-player adult school-life RPG written in Twine/SugarCube";
    homepage = "https://gitgud.io/Vrelnir/degrees-of-lewdity";
    license = lib.licenses.cc-by-nc-sa-40;
    mainProgram = "degrees-of-lewdity";
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
