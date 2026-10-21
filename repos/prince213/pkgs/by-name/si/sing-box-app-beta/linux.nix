{
  pname,
  meta,

  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchPnpmDeps,
  makeDesktopItem,
  rustPlatform,
  stdenvNoCC,
  sing-box-beta,
  sing-box-dashboard-beta,

  # nativeBuildInputs
  buf,
  copyDesktopItems,
  makeBinaryWrapper,
  pnpm_11,
  pnpmConfigHook,

  # buildInputs
  electron_43,
}:
let
  pnpm = pnpm_11;
  sing-box = sing-box-beta;
  electron = electron_43;

  boxdd = sing-box.overrideAttrs (previousAttrs: {
    subPackages = [ "experimental/boxdd" ];
    meta = previousAttrs.meta // {
      mainProgram = "boxdd";
    };
  });
  dashboard = sing-box-dashboard-beta.overrideAttrs {
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r . $out
      runHook postInstall
    '';
  };
in
buildNpmPackage (finalAttrs: {
  inherit pname;
  inherit (sing-box) version;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box-for-desktop";
    rev = "a5c75b44e0ccc99bef9ab6e15418dfeef563abfa";
    hash = "sha256-QWvdJbyJFAuWP+J+JBbrViqbcQmBFkyC6OGI/mgeFps=";
  };

  postPatch = ''
    rmdir dashboard
    ln -s ${dashboard} dashboard

    substituteInPlace build/sing-box-daemon.service \
      --replace-fail /opt/sing-box $out/opt/sing-box-app

    substituteInPlace scripts/generate.ts \
      --replace-fail \
        'const bufExecutable = ' \
        'const bufExecutable = "${lib.getExe buf}";'

    substituteInPlace scripts/sing-box.ts \
      --replace-fail \
        'findBoxDirectory(): string {' \
        'findBoxDirectory(): string { return "${sing-box.src}";'

    # https://github.com/electron/electron/issues/31121
    substituteInPlace src/main/{repair,resources,trayMenu}.ts \
      --replace-fail process.resourcesPath "\"$out/opt/sing-box-app/resources\""
  '';

  npmDeps = null;
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-m46qCgo5u5l1J3D4iLbJBJ0ruk/dRvNLBKTzyE6NHZo=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeBinaryWrapper
    pnpm
  ];
  npmConfigHook = pnpmConfigHook;

  preBuild = ''
    npm run generate
  '';

  buildPhase = ''
    runHook preBuild

    npm exec electron-vite build

    mkdir -p bin
    ln -s ${lib.getExe boxdd} bin/sing-box-daemon
    install -Dm755 ${finalAttrs.passthru.waylandMenu}/lib/libwayland_menu.so \
      bin/linux/${stdenvNoCC.hostPlatform.node.arch}/wayland_menu.node

    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    npm exec electron-builder -- \
      --dir \
      -c.electronDist=electron-dist \
      -c.extraMetadata.version=${finalAttrs.version}

    runHook postBuild
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "sing-box";
      desktopName = "sing-box";
      comment = "Client for sing-box, the universal proxy platform.";
      icon = "sing-box";
      exec = "sing-box-app %U";
      terminal = false;
      mimeTypes = [
        "application/x-sing-box-profile"
        "x-scheme-handler/sing-box"
      ];
      categories = [ "Network" ];
      startupWMClass = "sing-box";
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/sing-box-app
    cp -r release/*-unpacked/{locales,resources{,.pak}} $out/opt/sing-box-app

    mkdir -p $out/bin
    makeWrapper ${lib.getExe electron} $out/bin/sing-box-app \
      --inherit-argv0 \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --add-flag $out/opt/sing-box-app/resources/app.asar

    for i in 512x512 1024x1024; do
      install -Dm644 resources/icons/$i.png $out/share/icons/hicolor/$i/sing-box.png
    done
    install -Dm644 build/io.nekohasekai.sfl.metainfo.xml $out/share/metainfo/io.nekohasekai.sfl.metainfo.xml
    install -Dm644 ${./mime-info.xml} $out/share/mime/packages/sing-box.xml
    install -Dm644 build/io.nekohasekai.sfl.policy $out/share/polkit-1/actions/io.nekohasekai.sfl.policy
    install -Dm644 build/sing-box-daemon.service $out/lib/systemd/system/sing-box-daemon.service

    runHook postInstall
  '';

  passthru.waylandMenu = rustPlatform.buildRustPackage {
    pname = "${finalAttrs.pname}-wayland-menu";
    inherit (finalAttrs) version src;
    __structuredAttrs = true;
    sourceRoot = "${finalAttrs.src.name}/native/wayland-menu";
    cargoHash = "sha256-9nD8v9IjSPyWXL4cGodqGNwYg5SVt2NGf2E8dwh6Nc8=";
  };

  meta = meta // {
    branch = "dev";
    homepage = "https://github.com/SagerNet/sing-box-for-desktop";
    platforms = lib.platforms.linux;
  };
})
