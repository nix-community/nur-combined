{
  lib,
  mkWindowsAppNoCC,
  wine,
  fetchurl,
  makeDesktopItem,
  makeDesktopIcon,
  copyDesktopItems,
  copyDesktopIcons,
}:
mkWindowsAppNoCC rec {
  inherit wine;

  pname = "line";
  version = "9.2.0"; # :version:

  src = fetchurl {
    url = "https://dw.uptodown.net/dwn/d-j2hYrpH1l7Yai6-Sx1G1mqPZ5MdNdvZYHvkFptDlaA01rZdXIgXHjWINKSQ8LvppcrHM4GzCx27onCSeMKXZP59JAxTRumxrjU3pg7P5XAn7QPu6H9veP-q5sMFNJu/_pnWqtP0_KJFx2ijIPyobk_iET9Kaz7A7EFfUSyxdQLEVnr83cnXKgIqa69lhUh67ehKJSalm4XxanONZdLXlAPV-DPL2ugO2Lb3_WFKSYUkCKk5PkX_iOhoRK77ENC1/u3xGWdVjdntPmREAKX9emg6EGDshLP_15DrdnL4ERQMfh8qztNUCUJJtESyA9CERhmfg-flbf_9oUiLX72fyeg==/line-9-2-0-build-3431.exe";
    sha256 = "469421829b4eda17af44236f1a684fe970899324677f741f22033a2218b40bf5"; # :hash:
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
  '';

  winAppRun = ''
    $WINE start /unix "$WINEPREFIX/drive_c/users/$USER/AppData/Local/LINE/bin/LineLauncher.exe"
  '';

  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/line

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
      sha256 = "1kry4kab23d8knz1yggj3a0mdz56n7zf6g5hq4sbymdm103j4ksh";
    };
  };

  meta = with lib; {
    homepage = "https://line.me";
    description = "LINE is new level of communication, and the very infrastructure of your life.";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
