{
  bun,
  copyDesktopItems,
  docker-compose,
  electron_43,
  freerdp,
  lib,
  makeDesktopItem,
  makeWrapper,
  nodejs,
  pkgsCross,
  pkg-config,
  podman-compose,
  python3,
  source,
  stdenv,
  stdenvNoCC,
  udev,
  usbutils,
  writableTmpDirAsHomeHook,
}:

let
  electron = electron_43;
  appVersion = "0.9.0";
  version = "${appVersion}-unstable-${source.date}";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "winboat";
  inherit version;
  inherit (source) src;

  strictDeps = true;

  patches = [ ./prefer-wayland-freerdp.patch ];

  node_modules = stdenvNoCC.mkDerivation {
    pname = "${finalAttrs.pname}-node_modules";
    inherit (finalAttrs) version src;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
      "GIT_PROXY_COMMAND"
      "SOCKS_SERVER"
    ];

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
      bun install \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      cp -R node_modules "$out/"

      runHook postInstall
    '';

    dontFixup = true;

    outputHash = "sha256-P6TMRjwbTnXQgJsqQ9luhJAthKbWv2RWO+EIka1uwNk=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  guest-server = pkgsCross.mingwW64.callPackage ./guest-server.nix {
    inherit source;
    version = appVersion;
  };

  passthru.guest-server = finalAttrs.guest-server;

  nativeBuildInputs = [
    bun
    copyDesktopItems
    makeWrapper
    nodejs
    pkg-config
    python3
    writableTmpDirAsHomeHook
  ];

  buildInputs = [ udev ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    npm_config_nodedir = electron.headers;
  };

  postPatch = ''
    substituteInPlace package.json \
      --replace-fail "main/main.js" "src/main/main.ts"
  '';

  configurePhase = ''
    runHook preConfigure

    cp -R ${finalAttrs.node_modules}/node_modules .
    chmod -R u+w node_modules
    patchShebangs node_modules

    rm -rf guest_server/dist
    ln -s ${finalAttrs.guest-server} guest_server/dist

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    bun scripts/build.ts
    bun node_modules/electron-builder/cli.js --linux \
      --dir \
      -c.electronDist=${electron.dist} \
      -c.electronVersion=${electron.version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/libexec/winboat" "$out/share/winboat/guest_server"
    cp -r dist/linux-unpacked/resources "$out/share/winboat/resources"

    install -Dm444 \
      icons/winboat_logo.svg \
      "$out/share/icons/hicolor/256x256/apps/winboat.svg"

    ln -s "$out/share/winboat/resources/data" "$out/share/winboat/data"
    ln -s ../resources/guest_server "$out/share/winboat/guest_server/dist"

    makeWrapper ${freerdp}/bin/sdl-freerdp "$out/libexec/winboat/sdl-freerdp" \
      --set SDL_VIDEODRIVER wayland

    makeWrapper ${electron}/bin/electron "$out/bin/winboat" \
      --add-flag "$out/share/winboat/resources/app.asar" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --prefix PATH : "$out/libexec/winboat" \
      --suffix PATH : ${
        lib.makeBinPath [
          docker-compose
          freerdp
          podman-compose
          usbutils
        ]
      }

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "winboat";
      desktopName = "WinBoat";
      type = "Application";
      exec = "winboat %U";
      terminal = false;
      icon = "winboat";
      categories = [ "Utility" ];
    })
  ];

  meta = {
    mainProgram = "winboat";
    description = "Run Windows apps on Linux with seamless integration";
    homepage = "https://github.com/TibixDev/winboat";
    changelog = "https://github.com/TibixDev/winboat/commit/${source.src.rev}";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
})
