{
  autoPatchelfHook,
  buildNpmPackage,
  callPackage,
  copyDesktopItems,
  electron_41,
  ffmpeg,
  lib,
  makeDesktopItem,
  makeWrapper,
  nodejs_22,
  source ? callPackage ./source.nix { },
  stdenv,
  which,
  zip,
}:

let
  electron = electron_41;
in
buildNpmPackage (finalAttrs: {
  pname = "yanhekt-autoslides";
  inherit (source) version src;

  sourceRoot = "${finalAttrs.src.name}/autoslides";

  nodejs = nodejs_22;
  npmDepsHash = "sha256-Xk0+O8xlsvO3AXlPk/WV0rESt+KwiwUCK869l9SzHLk=";
  makeCacheWritable = true;
  npmRebuildFlags = [ "--ignore-scripts" ];
  npmBuildScript = "package";

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
    zip
  ];

  buildInputs = [ stdenv.cc.cc.lib ];

  postPatch = ''
    substituteInPlace forge.config.ts \
      --replace-fail \
        "icon: 'resources/img/icon'," \
        "electronZipDir: path.resolve(__dirname, '.electron-packager/electron-zips'), icon: 'resources/img/icon'," \
      --replace-fail \
        "...(!isDev ? [new FusesPlugin({" \
        "...(false ? [new FusesPlugin({"

    for file in \
      src/main/infra/ffmpegService.ts \
      src/main/infra/onnxModelService.ts \
      src/main/infra/sharpService.ts \
      src/main/extraction/qtExtractorService.ts \
      src/main/ipc/menuIpc.ts \
      src/main/platform/windowManager.ts
    do
      substituteInPlace "$file" \
        --replace-fail \
          "process.resourcesPath" \
          "(process.env.AUTOSLIDES_RESOURCES_PATH || process.resourcesPath)"
    done
  '';

  postConfigure = ''
    substituteInPlace node_modules/@electron-forge/core-utils/dist/electron-version.js \
      --replace-fail "return version" "return '${electron.version}'"

    electron_zip="$PWD/.electron-packager/electron-zips/electron-v${electron.version}-${stdenv.hostPlatform.node.platform}-${stdenv.hostPlatform.node.arch}.zip"
    mkdir -p "$(dirname "$electron_zip")"
    touch electron
    zip "$electron_zip" electron
    rm electron
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck

    npm test

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/yanhekt-autoslides"
    cp -r out/AutoSlides-linux-*/resources "$out/share/yanhekt-autoslides/"
    rm -rf \
      "$out/share/yanhekt-autoslides/resources/@img/"*linuxmusl* \
      "$out/share/yanhekt-autoslides/resources/ffmpeg-static" \
      "$out/share/yanhekt-autoslides/resources/ffprobe-static"

    makeWrapper ${lib.getExe electron} "$out/bin/autoslides" \
      --add-flags "$out/share/yanhekt-autoslides/resources/app.asar" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --prefix PATH : "${
        lib.makeBinPath [
          ffmpeg
          which
        ]
      }" \
      --set AUTOSLIDES_RESOURCES_PATH "$out/share/yanhekt-autoslides/resources" \
      --set ELECTRON_FORCE_IS_PACKAGED 1 \
      --inherit-argv0

    install -Dm444 \
      resources/img/icon.png \
      "$out/share/icons/hicolor/1024x1024/apps/autoslides.png"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "autoslides";
      desktopName = "AutoSlides";
      comment = finalAttrs.meta.description;
      exec = "autoslides %U";
      icon = "autoslides";
      categories = [ "Education" ];
      terminal = false;
      startupWMClass = "AutoSlides";
    })
  ];

  meta = {
    description = "北京理工大学延河课堂第三方客户端";
    homepage = "https://github.com/BIT-Admin/Yanhekt-AutoSlides";
    changelog = "https://github.com/BIT-Admin/Yanhekt-AutoSlides/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    mainProgram = "autoslides";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
