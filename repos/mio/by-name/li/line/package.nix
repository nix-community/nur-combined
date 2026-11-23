{
  lib,
  pkgs,
  wineWow64Packages,
  # enableMonoBootPrompt is broken with base Wine right now; full avoids the boot prompt.
  wine ? wineWow64Packages.full,
  fetchurl,
  makeDesktopItem,
  copyDesktopItems,
}:

let
  myLib = import ../../../lib { inherit pkgs; };
  inherit (myLib) mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
in
mkWindowsAppNoCC rec {
  inherit wine;

  pname = "line";
  version = "9.2.0"; # :version:

  src = fetchurl {
    url = "https://web.archive.org/web/20260113123008if_/https://dl5.filehippo.com/d36/e13/1aca8e2afb2dd5e0ed17abef69d7a56eb3/LINE_V9.2.0.3431.exe?Expires=1768350598&Signature=bc1a2cdefb659fd5c3892fe5146398dc5ac6fefa&url=https://filehippo.com/download_line/9.2.0.3431/&Filename=LINE_V9.2.0.3431.exe";
    hash = "sha256-RpQhgptO2hevRCNvGmhP6XCJkyRnf3QfIgM6Ihi0C/U="; # :hash:
  };

  dontUnpack = true;
  wineArch = "win64";
  persistRegistry = false;
  persistRuntimeLayer = true;
  enableMonoBootPrompt = false;
  graphicsDriver = "auto"; # Note: Does not work with Wayland
  nativeBuildInputs = [
    copyDesktopItems
    copyDesktopIcons
  ];

  fileMap = {
    "$HOME/.local/share/line/Data" = "drive_c/users/$USER/AppData/Local/LINE/Data";
    "$HOME/.local/share/line-call/Data" = "drive_c/users/$USER/AppData/Local/LineCall/Data";
  };

  enabledWineSymlinks = {
    desktop = false;
  };

  winAppInstall = ''
    winetricks win10
    $WINE ${src} /S
    wineserver -w
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Local/LINE/Data"
    winetricks --unattended cjkfonts >/dev/null 2>&1
  '';

  winAppRun = ''
    $WINE start /unix "$WINEPREFIX/drive_c/users/$USER/AppData/Local/LINE/bin/LineLauncher.exe"
  '';

  installPhase = ''
    runHook preInstall

    mv $out/bin/.launcher $out/bin/line

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "LINE";
      categories = [
        "Network"
        "Chat"
      ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = "line";

    src = fetchurl {
      url = "https://line.me/favicon-32x32.png";
      hash = "sha256-UE8iBwi1Vb80wbA84/6xpvxWgRryPR++nagNsdQkPs8=";
    };
  };

  meta = with lib; {
    homepage = "https://line.me";
    description = "LINE is new level of communication, and the very infrastructure of your life";
    license = licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "line";
  };
}
