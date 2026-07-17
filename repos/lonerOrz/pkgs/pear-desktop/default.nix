{
  lib,
  pnpm_11,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs,
  pnpmConfigHook,
  electron,
  libxkbcommon,
  libdrm,
  gtk3,
  nss,
  libX11,
  libXtst,
  libXScrnSaver,
  libgbm,
  alsa-lib,
  libnotify,
  xdg-utils,
  libuuid,
  at-spi2-core,
  wayland,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  commandLineArgs ? "",
}:
let
  pname = "pear-desktop";
  version = "3.12.0";
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
    owner = "pear-devs";
    repo = "pear-desktop";
    rev = "v${finalAttrs.version}";
    hash = "sha256-RSQPwsED3YK5VScVAXH3f8Lz74v1b2448gro1Vo22hg=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_11;
    fetcherVersion = 4;
    hash = "sha256-y4eLjikf9X/682RdK0ZvW7+GR1Ei82UJ5SVop09B9wg=";
  };

  buildInputs = [
    gtk3
    libnotify
    xdg-utils
    libxkbcommon
    libdrm
    libgbm
    nss
    alsa-lib
    libuuid
    at-spi2-core
    wayland
    libX11
    libXtst
    libXScrnSaver
  ];

  nativeBuildInputs = [
    electron
    makeWrapper
    nodejs
    pnpm_11
    pnpmConfigHook
    copyDesktopItems
  ];

  buildPhase = ''
    runHook preBuild

    pnpm run build

    runHook postBuild
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "${finalAttrs.pname}";
      desktopName = "Pear Desktop";
      comment = "Unofficial YouTube Music client";
      icon = "pear-desktop";
      exec = "pear-desktop";
      terminal = false;
      categories = [
        "AudioVideo"
        "Music"
      ];
    })
  ];

  installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/${finalAttrs.pname}
      cp -r dist/* $out/lib/${finalAttrs.pname}/
      cp -r node_modules $out/lib/${finalAttrs.pname}/

      # Do not open DevTools on app launch by setting ELECTRON_IS_DEV to 0.
      # see: https://github.com/sindresorhus/electron-is-dev/blob/main/index.js
      makeWrapper ${lib.getExe electron} $out/bin/$pname \
          --set ELECTRON_IS_DEV 0 \
          --set ELECTRON_RESOURCES_PATH $out/lib/${finalAttrs.pname} \
          --add-flags $out/lib/$pname/main/index.js \
          --add-flags "--disable-gpu --use-gl=swiftshader --enable-unsafe-swiftshader" \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-wayland-ime=true --wayland-text-input-version=3}}" \
          --add-flags ${lib.escapeShellArg commandLineArgs}

      install -Dm644 license "$out/share/licenses/${finalAttrs.pname}/LICENSE"

    ${lib.concatStringsSep "\n" (
      map (i: ''
        install -Dm644 assets/generated/icons/png/${i}x${i}.png \
          $out/share/icons/hicolor/${i}x${i}/apps/${finalAttrs.pname}.png
      '') icons
    )}

    runHook postInstall
  '';

  meta = {
    description = "Pear Desktop - unofficial YouTube Music desktop client";
    homepage = "https://github.com/pear-devs/pear-desktop";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = with lib.maintainers; [ lonerOrz ];
    binaryNativeCode = true;
  };
})
