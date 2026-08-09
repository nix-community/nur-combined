{
  pname,
  meta,

  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchPnpmDeps,
  makeDesktopItem,
  sing-box-beta,
  sing-box-dashboard,

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
  dashboard = sing-box-dashboard.overrideAttrs {
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
    rev = "ee516a8e9bba066498a48d2fe1d3a965f820798c";
    hash = "sha256-DFHTSsYkaL88X3LwMNq/cwX2NEhaOWfKBV9IrCV1vLc=";
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
  '';

  npmDeps = null;
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-lx2Ba7nwfuJO4y1fq9i1xfu+1RTWtyTDCsXnx3ffS7k=";
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

  meta = meta // {
    homepage = "https://github.com/SagerNet/sing-box-for-desktop";
    platforms = lib.platforms.linux;
  };
})
