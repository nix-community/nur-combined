{
  copyDesktopItems,
  makeDesktopItem,
  static-nix-shell,
  stdenvNoCC,
  zip,
}:
stdenvNoCC.mkDerivation {
  pname = "firefox-xdg-open";
  version = "0.1";
  src = ./.;

  nativeBuildInputs = [ zip ];

  buildPhase = ''
    runHook preBuild
    zip -j firefox.zip \
      background.js manifest.json
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install firefox.zip $out
    runHook postInstall
  '';

  passthru.extid = "@firefox-xdg-open";
  passthru.systemComponent = static-nix-shell.mkBash {
    pname = "xdg-open-scheme-handler";
    src = ./.;
    pkgs = [ "xdg-utils" ];

    nativeBuildInputs = [
      copyDesktopItems
    ];
    desktopItems = [
      (makeDesktopItem {
        name = "xdg-open";
        exec = "xdg-open-scheme-handler %U";
        desktopName = "xdg-open";
        comment = "Decodes xdg-open:... URIs, used to force applications to open links via the system handler";
        noDisplay = true;
      })
    ];
  };
}
