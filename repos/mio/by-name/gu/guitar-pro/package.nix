{
  lib,
  pkgs,
  wineWow64Packages,
  copyDesktopItems,
  fetchurl,
  makeDesktopItem,
  ...
}:
let
  myLib = import ../../../lib { inherit pkgs; };
  inherit (myLib) copyDesktopIcons makeDesktopIcon mkWindowsAppNoCC;
in
mkWindowsAppNoCC rec {
  wine = wineWow64Packages.full;
  pname = "guitar-pro";
  version = "8";
  src = fetchurl {
    url = "https://downloads.guitar-pro.com/gp8/stable/guitar-pro-8-setup.exe";
    hash = "sha256-ZC60AHJe50k94Wldr90swSg2xy7WxOo3eZ+9dn6jXW4=";
  };

  dontUnpack = true;
  wineArch = "win64";

  enableMonoBootPrompt = false;
  nativeBuildInputs = [
    copyDesktopItems
    copyDesktopIcons
  ];

  winAppInstall = ''
    $WINE start /unix ${src} /S /VERYSILENT /SUPPRESSMSGBOXES
    wineserver -w
  '';

  winAppRun = ''
    $WINE start /unix "$WINEPREFIX/drive_c/Program Files/Arobas Music/Guitar Pro 8/GuitarPro.exe" "$ARGS"
  '';

  installPhase = ''
    runHook preInstall
    mv $out/bin/.launcher $out/bin/${pname}
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "Guitar Pro";
      exec = pname;
      icon = pname;
      desktopName = "Guitar Pro";
      genericName = "Tablature Editor";
      categories = [
        "AudioVideo"
        "Audio"
      ];
    })
  ];

  meta = with lib; {
    mainProgram = pname;
    homepage = "https://www.guitar-pro.com/";
    description = "Guitar Pro 8 tablature editor (packaged via Wine)";
    license = licenses.unfree;
    maintainers = [ ];
    platforms = [
      "x86_64-linux"
    ];
  };
}
