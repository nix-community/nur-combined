{
  lib,
  stdenv,
  fetchFromGitHub,
  runCommand,
  fetchPnpmDeps,
  nodejs_22,
  pnpmConfigHook,
  pnpm,
  makeBinaryWrapper,
  copyDesktopItems,
  makeDesktopItem,
  electron,
  vulkan-loader,
}:

let
  version = "1.2.1";
  upstreamSrc = fetchFromGitHub {
    owner = "julian-alarcon";
    repo = "prospect-mail";
    rev = "v${version}";
    hash = "sha256-zamXAWsgkUodybt2lhjrE2BEyd/9T26mQYaxoxXFgjk=";
  };
  src = runCommand "prospect-mail-${version}-source" { } ''
    cp -r ${upstreamSrc} $out
    chmod -R u+w $out
    cp ${./pnpm-lock.yaml} $out/pnpm-lock.yaml
  '';
in
stdenv.mkDerivation (finalAttrs: {
  pname = "prospect-mail";
  inherit version src;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 2;
    hash = "sha256-AYtnKWhASmydcI2t02iDR4S80mj6dk50zbsDFko7tZ4=";
  };

  nativeBuildInputs = [
    nodejs_22
    pnpmConfigHook
    pnpm
    makeBinaryWrapper
    copyDesktopItems
  ];

  buildInputs = [
    vulkan-loader
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    NPM_CONFIG_MANAGE_PACKAGE_MANAGER_VERSIONS = "false";
  };

  buildPhase = ''
    runHook preBuild

    pnpm install --offline --frozen-lockfile --ignore-scripts

    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist
    rm -f electron-dist/libvulkan.so.1
    cp ${lib.getLib vulkan-loader}/lib/libvulkan.so.1 electron-dist

    npm exec -- electron-builder --dir \
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
