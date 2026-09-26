{
  lib,
  stdenv,
  fetchFromGitHub,
  electron_44,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  callPackage,
}:
let
  current = lib.trivial.importJSON ./version.json;

  pname = "weread-desktop";
  version = current.version;

  icons = [
    "16"
    "24"
    "32"
    "48"
    "64"
    "128"
    "256"
    "512"
    "1024"
  ];
in
stdenv.mkDerivation (finalAttrs: {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "NeilYXIN";
    repo = "WeRead_Desktop";
    rev = "v${finalAttrs.version}";
    hash = current.hash;
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      desktopName = "WeRead";
      comment = "Unofficial desktop client for WeRead";
      exec = "${finalAttrs.pname} %U";
      icon = finalAttrs.pname;
      categories = [ "Utility" ];
      terminal = false;
      startupWMClass = "weread";
    })
  ];

  postPatch = ''
    # disable auto update
    substituteInPlace lib/update-preferences.js \
      --replace-fail "automaticChecksEnabled: true" "automaticChecksEnabled: false"
  '';

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    appDir="$out/lib/${finalAttrs.pname}"
    install -d "$appDir"
    cp -r main.js renderer.js index.html styles.css lib package.json "$appDir/"

    install -d $out/bin
    makeWrapper ${lib.getExe electron_44} $out/bin/${finalAttrs.pname} \
      --add-flags "$appDir" \
      --set-default ELECTRON_OZONE_PLATFORM_HINT auto \
      --set-default GDK_BACKEND wayland,x11 \
      --set-default NIXOS_OZONE_WL 1 \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-wayland-ime=true --wayland-text-input-version=3}}"

    ${lib.concatStringsSep "\n" (
      map (size: ''
        install -Dm644 "assets/icons/png/${size}x${size}.png" \
          "$out/share/icons/hicolor/${size}x${size}/apps/${finalAttrs.pname}.png"
      '') icons
    )}

    runHook postInstall
  '';

  passthru.updateScript = callPackage ../../utils/update.nix {
    pname = "weread-desktop";
    versionFile = "pkgs/weread-desktop/version.json";
    fetchMetaCommand = "${(callPackage ../../utils/fetcher.nix { }).githubRelease {
      owner = "NeilYXIN";
      repo = "WeRead_Desktop";
    }}";
  };

  meta = {
    description = "Unofficial desktop client for WeRead";
    homepage = "https://github.com/NeilYXIN/WeRead_Desktop";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = finalAttrs.pname;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
