{
  lib,
  stdenv,
  pkgs,
  buildGoModule,
  fetchFromGitHub,
  fetchNpmDeps,
  npmHooks,
  copyDesktopItems,
  makeDesktopItem,
  autoPatchelfHook,
  wrapGAppsHook3,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "lampghost-dev";
  version = "0-unstable-2026-05-01";

  src = fetchFromGitHub {
    owner = "Catizard";
    repo = "lampghost";
    rev = "35f8eacc41c881ba84d5ca1c4506a14cb3743912";
    hash = "sha256-oOK4RlzlZ/cWek3RfeexD/xKCPVQEYBBWHyqIXLuOKQ=";
  };

  vendorHash = "sha256-RLs5BXXjob1HlA4AW2e29g4kln8dKOb++slmzE9JidU=";

  env = {
    CGO_ENABLED = 1;
    npmDeps = fetchNpmDeps {
      src = "${finalAttrs.src}/frontend";
      hash = "sha256-YYF6RfA3uE65QdwuJMV+NSvGYtmZRxwrVbQtijNyHRE=";
    };
    npmRoot = "frontend";
  };

  nativeBuildInputs = [
    pkgs.wails
    pkgs.pkg-config
    copyDesktopItems
    npmHooks.npmConfigHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    pkgs.gsettings-desktop-schemas
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs =
    [ ]
    ++ lib.optionals stdenv.hostPlatform.isLinux (
      with pkgs;
      [
        webkitgtk_4_1
        gtk3
        libsoup_3
        glib-networking
        libx11
        libxcursor
        libxrandr
        libxinerama
        libxi
        libxxf86vm
        libxfixes
        libxext
        libxcomposite
        libxdamage
        libxrender
        xvfb
        xorg-server
        at-spi2-core
      ]
    );

  buildPhase = ''
    runHook preBuild

    wails build -m -trimpath -devtools ${lib.optionalString stdenv.hostPlatform.isLinux "-tags webkit2_41"} -o lampghost-dev

    runHook postBuild
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "lampghost-dev";
      exec = "lampghost-dev";
      desktopName = "LampGhost (Dev Version)";
      comment = "Offline & Cross-platform beatoraja lamp viewer and more";
      categories = [ "Game" ];
      startupNotify = true;
      keywords = [ "beatoraja" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    install -Dm0755 build/bin/lampghost-dev $out/bin/lampghost-dev

    runHook postInstall
  '';

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--version=branch"
      ];
    };
  };

  meta = {
    description = "Offline & Cross-platform beatoraja lamp viewer and more";
    homepage = "https://github.com/Catizard/lampghost";
    changelog = "https://github.com/Catizard/lampghost/commits/main";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "lampghost-dev";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
