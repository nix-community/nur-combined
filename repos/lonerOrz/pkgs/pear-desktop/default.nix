{
  lib,
  pnpm,
  stdenv,
  fetchFromGitHub,
  electron,
  libxkbcommon,
  libdrm,
  gtk3,
  nss,
  xorg,
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
  version = "3.11.0";
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
    hash = "sha256-M8YFpeauM55fpNyHSGQm8iZieV0oWqOieVThhglKKPE=";
  };

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 2;
    hash = "sha256-xZQ8rnLGD0ZxxUUPLHmNJ6mA+lnUHCTBvtJTiIPxaZU=";
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
  ]
  ++ (with xorg; [
    libX11
    libXtst
    libXScrnSaver
  ]);

  nativeBuildInputs = [
    electron
    makeWrapper
    pnpm.configHook
    copyDesktopItems
  ];

  buildPhase = ''
    runHook preBuild

    pnpm install --frozen-lockfile
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

       makeWrapper ${lib.getExe electron} $out/bin/$pname \
          --add-flags $out/lib/$pname/main/index.js \
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
