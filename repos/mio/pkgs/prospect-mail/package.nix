{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  fixup-yarn-lock,
  git,
  nodejs_22,
  yarn,
  makeBinaryWrapper,
  copyDesktopItems,
  makeDesktopItem,
  electron,
  vulkan-loader,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "prospect-mail";
  version = "0.6.0-beta1-unstable";

  src = fetchFromGitHub {
    owner = "julian-alarcon";
    repo = "prospect-mail";
    rev = "dcf251f8f416e47e89cf1c4eb55f8b7e2dd7836a";
    hash = "sha256-XgIir6t9kqQxP0Lyb3OqbTZXIySUzlNlNUyk+yESPII=";
  };

  patchedYarnLock = builtins.toFile "yarn.lock" (
    builtins.replaceStrings
      [
        "\"@electron/node-gyp@git+https://github.com/electron/node-gyp.git#06b29aafb7708acef8b3669835c8a7857ebc92d2\":"
        "  resolved \"git+https://github.com/electron/node-gyp.git#06b29aafb7708acef8b3669835c8a7857ebc92d2\""
        "    \"@electron/node-gyp\" \"https://github.com/electron/node-gyp#06b29aafb7708acef8b3669835c8a7857ebc92d2\""
      ]
      [
        "\"@electron/node-gyp@10.2.0-electron.1\":"
        "  resolved \"https://registry.yarnpkg.com/@electron/node-gyp/-/node-gyp-10.2.0-electron.1.tgz#ca5f125dcd0ffb275797c0c418c0d64005e0f815\"\n  integrity sha512-YdpRE6qSNYyf7gBv1LBDc8OAs8f/mZthzM1k4pFzodNq8dBGf64MWC5Bq8VVlgdafjQXLpINHvtRAUC9uinoqw=="
        "    \"@electron/node-gyp\" \"10.2.0-electron.1\""
      ]
      (builtins.readFile "${finalAttrs.src}/yarn.lock")
  );

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = finalAttrs.patchedYarnLock;
    hash = "sha256-JNivSx299WnkvkVg4UJ5vgYe/ORX6VkehAwre4lP3ik=";
  };

  nativeBuildInputs = [
    nodejs_22
    yarn
    fixup-yarn-lock
    git
    makeBinaryWrapper
    copyDesktopItems
  ];

  buildInputs = [
    vulkan-loader
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    YARN_IGNORE_ENGINES = "1";
  };

  postPatch = ''
    cp ${finalAttrs.patchedYarnLock} yarn.lock
  '';

  configurePhase = ''
    runHook preConfigure

    export PATH=${lib.makeBinPath [ nodejs_22 ]}:$PATH
    export HOME="$TMPDIR"

    fixup-yarn-lock yarn.lock
    yarn config --offline set yarn-offline-mirror "$yarnOfflineCache"
    yarn install --offline --frozen-lockfile --ignore-engines --ignore-scripts --no-progress

    patchShebangs node_modules

    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist
    rm -f electron-dist/libvulkan.so.1
    cp ${lib.getLib vulkan-loader}/lib/libvulkan.so.1 electron-dist

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    yarn --offline run electron-builder --dir \
      -c.electronDist=electron-dist \
      -c.electronVersion=${electron.version} \
      -c.publish=never

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/prospect-mail
    cp -r dist/*-unpacked/{locales,resources{,.pak}} $out/share/prospect-mail

    install -Dm644 build/icon.png \
      $out/share/icons/hicolor/256x256/apps/prospect-mail.png

    makeWrapper ${lib.getExe electron} $out/bin/prospect-mail \
      --add-flags $out/share/prospect-mail/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "prospect-mail";
      exec = "prospect-mail %U";
      icon = "prospect-mail";
      desktopName = "Prospect Mail";
      comment = "Unofficial desktop mail client for Microsoft Outlook";
      categories = [
        "Network"
        "Office"
        "Email"
      ];
    })
  ];

  meta = {
    description = "Unofficial desktop mail client for Microsoft Outlook";
    homepage = "https://github.com/julian-alarcon/prospect-mail";
    license = lib.licenses.mit;
    mainProgram = "prospect-mail";
    inherit (electron.meta) platforms;
  };
})
