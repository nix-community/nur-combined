{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  buildNpmPackage,
  nodejs_24,
  pnpm_10,
  pnpmConfigHook,
  makeWrapper,
  electron,
  makeDesktopItem,
  git,
  glib,
  nss,
  nspr,
  atk,
  at-spi2-atk,
  at-spi2-core,
  cups,
  dbus,
  expat,
  libdrm,
  pango,
  cairo,
  gtk3,
  gdk-pixbuf,
  mesa,
  libgbm,
  vulkan-loader,
  libGL,
  wayland,
  libxkbcommon,
  alsa-lib,
  libsecret,
  udev,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
  libxshmfence,
  libxscrnsaver,
  jq,
}:

let
  electronLibs = [
    glib
    nss
    nspr
    atk
    at-spi2-atk
    at-spi2-core
    cups
    dbus
    expat
    libdrm
    pango
    cairo
    gtk3
    gdk-pixbuf
    mesa
    libgbm
    vulkan-loader
    libGL
    wayland
    libxkbcommon
    alsa-lib
    libsecret
    udev
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    libxshmfence
    libxscrnsaver
  ];

  sableSrc = fetchFromGitHub {
    owner = "SableClient";
    repo = "Sable";
    rev = "v1.18.3";
    hash = "sha256-yi70WBH0lDw1h4Oy6NNfi71kp32be3rtZDt3/C2e524=";
  };

  sableWebApp = stdenv.mkDerivation {
    pname = "sable-webapp";
    version = "dev";
    src = sableSrc;

    postPatch = ''
      sed -i '/@cloudflare\/vite-plugin/d' vite.config.ts
      sed -i '/cloudflare({/,/}),/d' vite.config.ts
      ${jq}/bin/jq 'del(.pnpm)' package.json > package.json.tmp
      mv package.json.tmp package.json

      cat > pnpm-workspace.yaml << 'YAMLEOF'
allowBuilds:
  '@sentry/cli': true
  '@swc/core': true
  cloudflared: true
  esbuild: true
  sharp: true
  unrs-resolver: true
  workerd: true
engineStrict: true
minimumReleaseAge: 1440
minimumReleaseAgeExclude:
  - '@sableclient/sable-call-embedded'
  - '@sableclient/twemoji-font'
overrides:
  jsdom>undici: '^7.28.0'
peerDependencyRules:
  allowedVersions:
    'folds>@vanilla-extract/css': '1.18.0'
    'folds>@vanilla-extract/recipes': '0.5.7'
    'folds>classnames': '2.5.1'
    'folds>react': '18.3.1'
    'folds>react-dom': '18.3.1'
YAMLEOF
    '';

    nativeBuildInputs = [
      nodejs_24
      pnpm_10
      pnpmConfigHook
      git
      jq
    ];

    pnpmDeps = fetchPnpmDeps {
      pnpm = pnpm_10;
      pname = "sable-webapp";
      version = "dev";
      src = sableSrc;
      fetcherVersion = 3;
      hash = "sha256-y5Gv/IQ5qkxhj8QHtv7p16bj/f3eHWXGoeZ4CPwkxhY=";
    };

    buildPhase = ''
      runHook preBuild
      NODE_OPTIONS='--max-old-space-size=8192' pnpm build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -r dist $out
      runHook postInstall
    '';
  };

  desktopItem = makeDesktopItem {
    name = "sable-desktop";
    exec = "sable-desktop %U";
    icon = "sable-desktop";
    desktopName = "Sable";
    comment = "Unofficial Electron desktop wrapper for Sable Matrix client";
    categories = [
      "Network"
      "InstantMessaging"
    ];
    mimeTypes = [ "x-scheme-handler/element" ];
  };

in
buildNpmPackage {
  pname = "sable-desktop";
  version = "1.0.6-1.18.3";

  src = fetchFromGitHub {
    owner = "goblinkingdev";
    repo = "sable-electron";
    rev = "v1.0.6-1.18.3";
    hash = "sha256-V6EzXjFaUUBdANR2QLa5JRxUv9Dri1LUsNA3e5UpFZY=";
  };

  npmDepsHash = "sha256-cMLUCqpNbREXLJ0muuU6kgM5RdSnFk5cPhToXEUo+iQ=";

  nativeBuildInputs = [
    nodejs_24
    makeWrapper
    electron
  ];

  buildInputs = electronLibs;

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    ELECTRON_OVERRIDE_DIST_PATH = "${electron}/libexec/electron";
  };

  buildPhase = ''
    runHook preBuild
    mkdir -p sable
    cp -r ${sableWebApp} sable/dist
    npm run build:electron
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/sable-desktop $out/bin $out/share/applications
    cp -r dist-electron package.json $out/lib/sable-desktop/
    cp -r node_modules $out/lib/sable-desktop/node_modules
    cp -r ${sableWebApp} $out/lib/sable-desktop/dist
    cp -r resources $out/lib/sable-desktop/resources
    makeWrapper ${electron}/bin/electron $out/bin/sable-desktop \
      --add-flags "$out/lib/sable-desktop" \
      --set LD_LIBRARY_PATH "${lib.makeLibraryPath electronLibs}:/run/opengl-driver/lib"
    cp ${desktopItem}/share/applications/sable-desktop.desktop $out/share/applications/
    runHook postInstall
  '';

  passthru = {
    desktopItem = desktopItem;
  };

  meta = with lib; {
    description = "Unofficial Electron desktop wrapper for Sable Matrix client";
    homepage = "https://github.com/goblinkingdev/sable-electron";
    changelog = "https://github.com/goblinkingdev/sable-electron/commits/master";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ "goblinkingdev" ];
    mainProgram = "sable-desktop";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
