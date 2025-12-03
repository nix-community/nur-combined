{
  copyDesktopItems,
  makeDesktopItem,
  static-nix-shell,
  stdenvNoCC,
  wrapFirefoxAddonsHook,
  zip,
}:
stdenvNoCC.mkDerivation {
  pname = "firefox-xdg-open";
  version = "0.1";
  src = ./.;

  nativeBuildInputs = [
    wrapFirefoxAddonsHook
    zip
  ];

  buildPhase = ''
    runHook preBuild
    zip -j firefox.zip \
      background.js manifest.json
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir $out
    install firefox.zip $out/$extid.xpi
    runHook postInstall
  '';

  extid = "@firefox-xdg-open";

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
        comment = "Decodes xdg-open URIs used to force applications to open links via the system handler";
        noDisplay = true;
        #v not sure which of these are necessary; borrowed from Zoom.desktop, as that seems to better integrate w/ Firefox.
        terminal = false;
        mimeTypes = [
          "x-scheme-handler/xdg-open"
          "application/xdg-open"
        ];
        categories = [ "Network" "Application" ];  #< TODO: remove
        extraConfig = {
          X-KDE-Protocols = "xdg-open;";
        };
      })
    ];
  };
}
