{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm,
  fetchPnpmDeps,
  pnpmConfigHook,
  electron,
  pkg-config,
  libusb1,
  udev,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  writeShellScriptBin,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nanokvm-usb";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "sipeed";
    repo = "NanoKVM-USB";
    rev = finalAttrs.version;
    hash = "sha256-OvcDQxAdN5xaQS942BpLAK3cnG3ha0hl9r2xRMZM2IQ=";
  };

  sourceRoot = "${finalAttrs.src.name}/desktop";

  nativeBuildInputs = [
    pnpm
    pnpmConfigHook
    nodejs
    pkg-config
    makeWrapper
  ]
  ++ lib.optionals stdenv.isLinux [
    copyDesktopItems
  ]
  ++ lib.optionals stdenv.isDarwin [
    # mock codesign
    (writeShellScriptBin "codesign" "true")
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      sourceRoot
      ;
    inherit pnpm;
    fetcherVersion = 2;
    hash = "sha256-KwLodj8MQZHQIi4I1wHZ8U0WlGYbB9yQPUimMWOmxqU=";
  };

  buildInputs = lib.optionals stdenv.isLinux [
    libusb1
    udev
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    CSC_IDENTITY_AUTO_DISCOVERY = "false";
  };

  buildPhase = ''
    runHook preBuild

    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    ${lib.optionalString stdenv.isDarwin ''
      # Remove problematic macOS-specific build configs
      substituteInPlace electron-builder.yml \
        --replace-fail "afterSign: './notarize.js'" ""
    ''}

    pnpm run build

    pnpm exec electron-builder \
      --dir \
      -c.electronDist=electron-dist \
      -c.electronVersion=${electron.version} \
      ${lib.optionalString stdenv.isDarwin "-c.mac.notarize=false"}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    ${lib.optionalString stdenv.isLinux ''
      # Install application files
      mkdir -p $out/opt/${finalAttrs.pname}
      cp -r dist/*-unpacked/{locales,resources{,.pak}} $out/opt/${finalAttrs.pname}/

      # Install icon
      install -Dm644 build/icons/512x512.png $out/share/icons/hicolor/512x512/apps/${finalAttrs.pname}.png

      # Create wrapper
      mkdir -p $out/bin
      makeWrapper ${lib.getExe electron} $out/bin/${finalAttrs.pname} \
        --add-flags $out/opt/${finalAttrs.pname}/resources/app.asar \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
        --inherit-argv0
    ''}

    ${lib.optionalString stdenv.isDarwin ''
      mkdir -p $out/Applications
      cp -r dist/mac*/NanoKVM-USB.app $out/Applications

      # Copy app-update.yml for electron-updater
      cp dev-app-update.yml $out/Applications/NanoKVM-USB.app/Contents/Resources/app-update.yml

      mkdir -p $out/bin
      makeWrapper $out/Applications/NanoKVM-USB.app/Contents/MacOS/NanoKVM-USB $out/bin/${finalAttrs.pname}
    ''}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      exec = finalAttrs.pname;
      icon = finalAttrs.pname;
      desktopName = "NanoKVM-USB";
      comment = finalAttrs.meta.description;
      categories = [
        "System"
        "RemoteAccess"
      ];
      keywords = [
        "KVM"
        "Remote"
        "USB"
        "NanoKVM"
      ];
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "NanoKVM-USB Desktop (Electron + React client)";
    homepage = "https://github.com/sipeed/NanoKVM-USB";
    license = licenses.gpl3Only;
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = finalAttrs.pname;
    maintainers = [ maintainers.codgician ];
  };
})
