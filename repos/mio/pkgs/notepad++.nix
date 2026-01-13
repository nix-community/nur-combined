{
  lib,
  build,
  pkgs,
  wine,
  ...
}:
let
  inherit (pkgs) copyDesktopItems fetchurl makeDesktopItem;
  inherit (build) copyDesktopIcons makeDesktopIcon mkWindowsAppNoCC;
in
mkWindowsAppNoCC rec {
  inherit wine;
  pname = "notepad-plus-plus";
  version = "8.7.3";
  src = fetchurl {
    url = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v${version}/npp.${version}.Installer.exe";
    sha256 = "0qb8x7fy2840wvc0ypmqk0zn806va3zrpdz6cdzrqwcyn76j3ymf";
  };

  dontUnpack = true;
  wineArch = "win32";

  fileMap = {
    "$HOME/.config/Notepad++" = "drive_c/users/$USER/AppData/Roaming/Notepad++";
  };

  enableMonoBootPrompt = false;
  nativeBuildInputs = [
    copyDesktopItems
    copyDesktopIcons
  ];

  winAppInstall = ''
    $WINE start /unix ${src} /S
    wineserver -w
    rm -f "$WINEPREFIX/drive_c/Program Files/Notepad++/uninstall.exe"
    rm -fR "$WINEPREFIX/drive_c/Program Files/Notepad++/updater"
  '';

  winAppRun = ''
    $WINE start /unix "$WINEPREFIX/drive_c/Program Files/Notepad++/notepad++.exe" "$ARGS"
  '';

  installPhase = ''
    runHook preInstall
    ln -s $out/bin/.launcher $out/bin/${pname}
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "Notepad++";
      exec = pname;
      icon = pname;
      desktopName = "Notepad++";
      genericName = "Text Editor";
      mimeTypes = [ "text/plain" ];
      categories = [
        "Utility"
        "TextEditor"
      ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    icoIndex = 2;
    src = fetchurl {
      url = "https://notepad-plus-plus.org/favicon.ico";
      sha256 = "1av2m6m665ccfngnzqnbsnv2aky907p2c6ggvfxrwbp70szgj9vi";
    };
  };

  meta = with lib; {
    mainProgram = pname;
    homepage = "https://notepad-plus-plus.org/";
    description = "A text and source code editor";
    license = licenses.gpl3Plus;
    maintainers = [ "maydayv7" ];
    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
  };
}
