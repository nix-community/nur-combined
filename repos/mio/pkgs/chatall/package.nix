{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchNpmDeps,
  npmHooks,
  nodejs_22,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  electron,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chatall";
  version = "1.85.110";

  src = fetchFromGitHub {
    owner = "ai-shifu";
    repo = "ChatALL";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Zz1gYLgrx/oDURR/mke9MnPUR2zdjup+DnUXZNU4fxg=";
  };

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-cCIh0B/oUz34cbw+3ttms2O7DKKvLjBiYf97XrgerS0=";
  };

  nativeBuildInputs = [
    nodejs_22
    npmHooks.npmConfigHook
    makeWrapper
    copyDesktopItems
  ];

  makeCacheWritable = true;

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = 1;

  buildPhase = ''
    runHook preBuild

    npm run electron:build -- \
      --dir \
      -c.electronDist=${electron.dist} \
      -c.electronVersion=${electron.version} \
      -c.publish=never

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/chatall
    cp -r dist/*-unpacked/{locales,resources{,.pak}} $out/share/chatall

    install -Dm644 src/assets/icon.png \
      $out/share/icons/hicolor/512x512/apps/chatall.png

    makeWrapper ${lib.getExe electron} $out/bin/chatall \
      --add-flags $out/share/chatall/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "chatall";
      exec = "chatall %U";
      icon = "chatall";
      desktopName = "ChatALL";
      comment = finalAttrs.meta.description;
      categories = [
        "Network"
        "Chat"
      ];
      startupWMClass = "ChatALL";
    })
  ];

  meta = {
    description = "Chat with multiple AI bots and discover the best";
    homepage = "https://github.com/ai-shifu/ChatALL";
    license = lib.licenses.asl20;
    mainProgram = "chatall";
    platforms = lib.platforms.linux;
  };
})
