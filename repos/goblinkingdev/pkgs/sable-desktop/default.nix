{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  buildNpmPackage,
  nodejs_24,
  pnpm,
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
    rev = "v1.17.0";
    hash = "sha256-hWh/xfyuEQTjqf/k5HJ32wFdOHRWXWqAh6q1pdk4Ih4=";
  };

  sableWebApp = stdenv.mkDerivation {
    pname = "sable-webapp";
    version = "dev";
    src = sableSrc;

    postPatch = ''
      sed -i '/@cloudflare\/vite-plugin/d' vite.config.ts
      sed -i '/cloudflare({/,/}),/d' vite.config.ts
    '';

    nativeBuildInputs = [
      nodejs_24
      pnpm
      pnpmConfigHook
      git
    ];

    pnpmDeps = fetchPnpmDeps {
      pname = "sable-webapp";
      version = "dev";
      src = sableSrc;
      fetcherVersion = 3;
      hash = "sha256-DlWFD0AJp/KD15SU8/1L0RAj7J+66zY8hwiu19AlO0I=";
    };

    buildPhase = ''
      runHook preBuild
      pnpm build
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
  version = "1.0.5-1.17.0";

  src = fetchFromGitHub {
    owner = "goblinkingdev";
    repo = "sable-electron";
    rev = "v1.0.5-1.17.0";
    hash = "sha256-zjx07fMTu2yY+5lav9aQwRmmQCmSxEl9nGYLftYFiog=";
  };

  npmDepsHash = "sha256-x+QLU5byWDDO5ATyGlNRuRgnA07zF9SMrJn83DAqmW8=";

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
