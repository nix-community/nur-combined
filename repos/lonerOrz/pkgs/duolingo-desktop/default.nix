{
  lib,
  stdenv,
  fetchzip,
  fetchurl,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  electron,
  callPackage,
}:
let
  current = lib.trivial.importJSON ./version.json;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "duolingo-desktop";
  version = current.version;

  src = fetchzip {
    url = "https://github.com/hmlendea/dl-desktop/releases/download/v${finalAttrs.version}/dl-desktop_${finalAttrs.version}_linux.zip";
    hash = current.hash;
    stripRoot = false;
  };

  icon = fetchurl {
    url = "https://raw.githubusercontent.com/hmlendea/dl-desktop/v${finalAttrs.version}/icon.png";
    hash = current.icon_hash;
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    electron
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "duolingo-desktop";
      desktopName = "DL: language lessons";
      comment = "Unofficial desktop client for Duolingo language learning";
      exec = "duolingo-desktop";
      icon = "duolingo-desktop";
      categories = [ "Education" ];
      terminal = false;
      startupWMClass = "ro.go.hmlendea.DL-Desktop";
    })
  ];

  installPhase = ''
    runHook preInstall

    appDir="$out/lib/${finalAttrs.pname}"
    install -d $appDir
    cp -r ./* $appDir/

    install -d $out/bin
    makeWrapper ${electron}/bin/electron $out/bin/duolingo-desktop \
      --add-flags $appDir/resources/app.asar \
      --set-default ELECTRON_OZONE_PLATFORM_HINT auto \
      --set-default GDK_BACKEND wayland,x11 \
      --set-default NIXOS_OZONE_WL 1

    install -d $out/share/icons/hicolor/512x512/apps
    install -m 0644 $icon $out/share/icons/hicolor/512x512/apps/duolingo-desktop.png

    runHook postInstall
  '';

  passthru.updateScript = callPackage ../../utils/update.nix {
    pname = "duolingo-desktop";
    versionFile = "pkgs/duolingo-desktop/version.json";
    fetchMetaCommand = "${(callPackage ../../utils/fetcher.nix { }).githubRelease {
      owner = "hmlendea";
      repo = "dl-desktop";
    }}";
  };

  meta = {
    description = "Unofficial desktop client for Duolingo";
    homepage = "https://github.com/hmlendea/dl-desktop";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ lonerOrz ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "duolingo-desktop";
  };
})
