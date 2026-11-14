{
  buildGoModule,
  callPackage,
  copyDesktopItems,
  lib,
  makeDesktopItem,
  pkg-config,
  wrapGAppsHook3,
  gtk3,
  source ? callPackage ./source.nix { },
  wayland,
  webkitgtk_4_1,
}:

buildGoModule (finalAttrs: {
  pname = "magpie";
  inherit (source) version src vendorHash;

  patches = [ ./desktop-registration.patch ];
  subPackages = [ "." ];
  tags = [
    "production"
    "gtk3"
  ];
  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  nativeBuildInputs = [
    pkg-config
    copyDesktopItems
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    wayland
    webkitgtk_4_1
  ];

  # The full upstream suite needs external agents and a desktop session.
  checkPhase = ''
    runHook preCheck
    go test -tags=production,gtk3 ./internal/gui -run '^(TestRegisterScheme|TestKeepWebData)$'
    runHook postCheck
  '';

  postInstall = ''
    install -Dm644 internal/gui/icon-256.png $out/share/icons/hicolor/256x256/apps/magpie.png
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "magpie";
      exec = "magpie %u";
      icon = "magpie";
      desktopName = "magpie";
      comment = "One local gateway for the model every coding agent uses";
      startupWMClass = "magpie";
      categories = [
        "Development"
        "Utility"
      ];
      mimeTypes = [ "x-scheme-handler/magpie" ];
    })
    (makeDesktopItem {
      name = "magpie-ccswitch";
      exec = "magpie %u";
      desktopName = "magpie (ccswitch:// links)";
      noDisplay = true;
      mimeTypes = [ "x-scheme-handler/ccswitch" ];
    })
  ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    test -x $out/bin/magpie
    test -f $out/share/applications/magpie.desktop
    test -f $out/share/icons/hicolor/256x256/apps/magpie.png
    $out/bin/magpie --version

    runHook postInstallCheck
  '';

  meta = {
    description = "One local gateway for the model every coding agent uses";
    homepage = "https://usemagpie.ai";
    changelog = "https://github.com/yetone/magpie-releases/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "magpie";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
