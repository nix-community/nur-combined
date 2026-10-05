{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm_11,
  jq,
  yq,
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
  autoPatchelfHook,
}:

let
  # Pin the pnpm major so the offline-store layout (and therefore
  # `pnpmDeps.hash`) is stable across nixpkgs bumps of the default `pnpm`
  # attribute. pnpm 11 supports the upstream lockfile's `lockfileVersion: '9.0'`.
  pnpm = pnpm_11;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "nanokvm-usb";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "sipeed";
    repo = "NanoKVM-USB";
    rev = "v${finalAttrs.version}";
    hash = "sha256-bdU64T+5Zkqn2FX2EmHWcWh85DWBNV6k5xKYEJQn+l0=";
  };

  sourceRoot = "${finalAttrs.src.name}/desktop";

  nativeBuildInputs = [
    pnpm
    pnpmConfigHook
    nodejs
    jq
    yq
    pkg-config
    makeWrapper
  ]
  ++ lib.optionals stdenv.isLinux [
    copyDesktopItems
    autoPatchelfHook
  ]
  ++ lib.optionals stdenv.isDarwin [
    # mock codesign
    (writeShellScriptBin "codesign" "true")
  ];

  pnpmInstallFlags = [ "--shamefully-hoist" ];
  # pnpm 11 moved overrides and build approvals into pnpm-workspace.yaml.
  # Preserve the upstream policy: allow only Electron's install script.
  prePnpmInstall = ''
    jq '.pnpm | { overrides, confirmModulesPurge: false, shamefullyHoist: true, allowBuilds: { "@serialport/bindings-cpp": false, electron: true, "electron-winstaller": false, esbuild: false } }' package.json | yq -y '.' > pnpm-workspace.yaml
    jq 'del(.pnpm)' package.json > package.json.tmp
    mv package.json.tmp package.json
    rm .npmrc
  '';


  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      sourceRoot
      prePnpmInstall
      ;
    inherit pnpm;
    nativeBuildInputs = [ jq yq ];
    fetcherVersion = 4;
    hash = "sha256-iQ55ubHccv5+DVOU0iAyPKH3kFwOS/Wg+cOAHAN7r3Q=";
  };

  buildInputs = lib.optionals stdenv.isLinux [
    libusb1
    udev
    stdenv.cc.cc.lib
  ];

  # Ignore dependencies in prebuilt binaries for other platforms (Alpine musl, Android)
  autoPatchelfIgnoreMissingDeps = [
    "libc.musl-x86_64.so.1"
    "libc.musl-aarch64.so.1"
    "libc++_shared.so"
    "liblog.so"
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

      # Copy node_modules for runtime dependencies (externalized by electron-vite)
      cp -r node_modules $out/opt/${finalAttrs.pname}/resources/

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

  # Upstream tag `1.1.0` is missing the `v` prefix used by every other release,
  # which trips nix-update's version sorting (alpha < numeric) and causes it to
  # pick `1.1.0` as the latest. Restrict to tags shaped like `vX.Y.Z` so the
  # comparison stays sane.
  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "v(.*)"
    ];
  };

  meta = with lib; {
    description = "NanoKVM-USB Desktop (Electron + React client)";
    homepage = "https://github.com/sipeed/NanoKVM-USB";
    license = licenses.gpl3Only;
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = finalAttrs.pname;
    maintainers = [ maintainers.codgician ];
  };
})
